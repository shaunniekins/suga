#!/usr/bin/env python3
"""Local preview of the site, with the same rewrites, redirects and headers
as Vercel (read from vercel.json), so /privacy, /terms and the security
headers behave as they will in production.

    python3 tool/serve_site.py            # serves build/site (run tool/build_site.sh first)
    python3 tool/serve_site.py website    # serves website/ directly: no build, no /app/
    python3 tool/serve_site.py --port 9000

Then open http://localhost:8000 (and /app/ for the web app).
"""
import argparse
import http.server
import json
import re
from functools import partial
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
parser.add_argument("directory", nargs="?", default="build/site")
parser.add_argument("--port", type=int, default=8000)
args = parser.parse_args()

site = (ROOT / args.directory).resolve()
if not (site / "index.html").exists():
    raise SystemExit(f"No index.html in {site}. Run ./tool/build_site.sh first.")

config = json.loads((ROOT / "vercel.json").read_text())


def pattern(source):
    # Enough of Vercel's path syntax for our vercel.json: (...) groups are regex.
    return re.compile("^" + source + "$")


headers = [(pattern(h["source"]), h["headers"]) for h in config.get("headers", [])]
rewrites = [(pattern(r["source"]), r["destination"]) for r in config.get("rewrites", [])]
redirects = [(pattern(r["source"]), r["destination"]) for r in config.get("redirects", [])]


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.route():
            super().do_GET()

    def do_HEAD(self):
        if self.route():
            super().do_HEAD()

    def route(self):
        """Applies redirects (answering them) and rewrites. Returns whether
        the request still needs a file served."""
        path, _, query = self.path.partition("?")
        self.request_path = path
        for source, destination in redirects:
            if source.match(path):
                self.send_response(308)
                self.send_header("Location", destination + (f"?{query}" if query else ""))
                self.end_headers()
                return False
        for source, destination in rewrites:
            if source.match(path):
                self.path = destination
                break
        return True

    def end_headers(self):
        path = getattr(self, "request_path", self.path)
        for source, values in headers:
            if source.match(path):
                for header in values:
                    if header["key"].lower() != "cache-control":
                        self.send_header(header["key"], header["value"])
        # Always fetch fresh files while previewing, so edits show on reload.
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), partial(Handler, directory=str(site)))
print(f"Serving {site.relative_to(ROOT)} at http://localhost:{args.port}  (Ctrl+C to stop)")
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
