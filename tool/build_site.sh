#!/usr/bin/env bash
# Builds the deployable site in build/site:
#   /            landing page, privacy policy and terms (static, from website/)
#   /app/        the Flutter web app
# Vercel runs this (see vercel.json); it works the same locally.
set -euo pipefail
cd "$(dirname "$0")/.."

# Keep in step with the Flutter version used for the mobile releases.
FLUTTER_VERSION="${FLUTTER_VERSION:-3.38.3}"

if ! command -v flutter >/dev/null 2>&1; then
  # Vercel's build image (Amazon Linux) has no Flutter SDK; fetch the pinned
  # release. Flutter's first run needs unzip to unpack the Dart SDK.
  if ! command -v unzip >/dev/null 2>&1 && command -v dnf >/dev/null 2>&1; then
    dnf install -y -q unzip
  fi
  sdk="${HOME}/flutter-${FLUTTER_VERSION}"
  if [ ! -x "${sdk}/bin/flutter" ]; then
    git clone --quiet --depth 1 --branch "${FLUTTER_VERSION}" \
      https://github.com/flutter/flutter.git "${sdk}"
  fi
  export PATH="${sdk}/bin:${PATH}"
  flutter config --no-analytics >/dev/null
fi

out=build/site
rm -rf "${out}"
mkdir -p "${out}"
cp -R website/. "${out}/"

flutter pub get
# --no-web-resources-cdn serves the rendering engine and fonts from our own
# domain instead of Google's CDN, so using the app contacts no third party.
# --no-wasm-dry-run silences the "try --wasm" hint: the JavaScript build is
# the tested one. A --wasm build is faster in current browsers (and falls back
# to JavaScript in older ones), but test the web microphone with it first.
flutter build web --release \
  --base-href /app/ \
  --no-web-resources-cdn \
  --no-wasm-dry-run \
  --output "${out}/app"

echo "Built ${out}: landing at /, app at /app/"
