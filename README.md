# Suga

> Sound becomes light. A beat-reactive music visualizer for your phone, tablet or browser.

Suga (Cebuano for "light") turns the sound around you into light. Play music
and it listens through your microphone, finds the beat, and fills the screen
with color that moves with it, like a Winamp visualizer for the whole room.

🌐 **Website:** [suga.shaunniekins.com](https://suga.shaunniekins.com) · [Open the web app](https://suga.shaunniekins.com/app/) · [Privacy policy](https://suga.shaunniekins.com/privacy) · [Terms of use](https://suga.shaunniekins.com/terms)

---

## ✨ Features

- **Hears the beat.** Suga analyzes the microphone the way old Winamp
  visualizers did: a frequency spectrum (bass to treble), loudness with
  automatic gain (quiet background music and a loud party both use the full
  range), and beat detection on kicks and claps. Audio is never recorded or
  stored.
- **Every beat changes the light.** Colors come from club palettes (Neon,
  Sunset, Acid, Ocean, Fire) that shift one step on every beat. Every 16 beats
  the next palette takes over.
- **Eight modes.** Tap the mode pill at the bottom of the screen, or swipe it
  right, for the next mode; swipe it left for the previous one:
  - **Disco:** colored beams sweep from a center light while mirror-ball
    sparkles drift past; the room flashes the next color on each beat.
  - **Spectrum:** Winamp-style bars from bass to treble with falling peak
    caps and a floor reflection.
  - **Pulse:** rings burst outward on every beat around a spinning circular
    spectrum.
  - **Assorted:** jumps to a new hue on each beat; brightness follows
    loudness.
  - **Black & white:** flips between black and white on each beat.
  - **Gradient:** a radial glow in the palette's color that swells with
    loudness and kicks on the beat.
  - **Tiles:** a mosaic that sparkles with loudness and bursts on each beat.
  - **Level:** a full-screen LED meter with a falling peak marker.
- **Your lineup.** The **Customize modes** button (top right) lets you switch
  off modes you don't want and drag the rest into your own order. Suga
  remembers the lineup on the device. At least one mode always stays on.
- **Immersive and awake.** The visualizer hides the system bars and keeps the
  screen on. Tap anywhere to show or hide the controls.
- **Photosensitivity-safe.** Beats are capped below three per second (WCAG
  2.3.1), so full-screen flashes never exceed that rate. With the system
  reduced-motion setting on, the beat pulse switches off, rotation slows, and
  Black & white fades through grays instead of flipping.

## Using Suga

1. Tap the glowing logo on the home screen.
2. Allow microphone access when asked. If you've blocked it before, Suga
   offers a shortcut to the app's settings.
3. Play music or make some noise. Music with a clear kick drum gives the
   strongest beats.
4. Tap the screen to show the controls. Tap or swipe the mode pill to change
   mode, tap **Customize modes** to choose and order them, and tap **×** or
   go back to stop.

---

## 🛍️ Store listing

> **Keep this section in sync with Play Console and App Store Connect.** If you
> change the name, descriptions or keywords here, update the stores too, and
> vice versa. Every feature claim must stay true to the app. Graphics, sizes
> and the privacy forms are in [`store/README.md`](store/README.md).

**App name** (Play max 30 chars, App Store max 30; currently 22)

```
Suga: Music Visualizer
```

The home-screen label stays **Suga**. App Store names must be unique; if this
one is taken, try `Suga: Music Light Show`.

**Short description** — Google Play (max 80 chars; currently 73)

```
Turn music into light. A beat-reactive visualizer that fills your screen.
```

**Subtitle** — App Store (max 30 chars; currently 28)

```
Light that moves to the beat
```

**Promotional text** — App Store (max 170 chars; currently 130; can change without a review)

```
Put on a song and watch your screen light up to the beat. Eight modes, from disco beams to Winamp-style bars. Nothing is recorded.
```

**Keywords** — App Store (max 100 bytes, comma-separated, no spaces after commas; currently 100)

```
music,visualizer,light show,disco,party,beat,winamp,spectrum,equalizer,sound,lights,dj,club,rave,led
```

**Full description** — Google Play and App Store (max 4,000 chars; currently ~2,090). On the App Store, write **Reduce Motion** instead of **remove animations**.

```
Suga turns the sound in the room into light. Put on a song, set your phone down, and watch the screen pulse, sweep and glow in time with the music. It's like the music visualizers you remember from Winamp, but it listens through your microphone, so it works with anything you can hear: a speaker, a TV, a guitar, or a room full of people singing.

LIGHT THAT FOLLOWS THE BEAT
Suga hears the kick drums and the claps and changes color on every beat. It follows the shape of the music too, from deep bass to bright treble, about forty times a second. Quiet background music and a loud party both get the full show, because Suga adjusts to the room.

EIGHT MODES
• Disco: colored beams sweep from a light in the middle, with mirror-ball sparkles
• Spectrum: Winamp-style bars from bass to treble, with falling peaks
• Pulse: a ring of color bursts outward on every beat
• Assorted: a new color on every beat, brighter when it's louder
• Black & white: the screen flips between black and white on the beat
• Gradient: a glow that swells with the music
• Tiles: a mosaic that sparkles and bursts on the beat
• Level: a full-screen LED meter

YOUR SHOW, YOUR WAY
• Tap or swipe the mode button to change mode
• Switch off the modes you don't want and put the rest in your own order
• Five color palettes (Neon, Sunset, Acid, Ocean and Fire) that shift on every beat
• Full screen, and the screen stays on while the show runs
• Works on phones and tablets

GENTLE ON THE EYES
Full-screen flashes are kept below three per second, the limit accessibility guidelines set for flashing content. If your phone's remove animations setting is on, Suga switches off the beat pulse and slows down. If you or anyone watching is sensitive to flashing light, please take care.

NOTHING IS RECORDED
Suga uses the microphone only to measure sound, right on your phone, while the show is running. Audio is never recorded, saved or sent anywhere. There's no account, no ads and no analytics, and the Android app doesn't even ask for internet access.

Suga means "light" in Cebuano. Play something and let it shine.
```

**Category:** Music (App Store primary; Entertainment secondary) · Music & Audio (Google Play).
**Links:** website `https://suga.shaunniekins.com` · privacy `https://suga.shaunniekins.com/privacy` · support email `contact@shaunniekins.com`.

---

## 🌐 Website and web app

One Vercel project serves everything from **suga.shaunniekins.com**:

| URL | What | Source |
|---|---|---|
| `/` | Landing page | [`website/index.html`](website/index.html) |
| `/privacy`, `/terms` | Privacy policy, terms of use | [`website/`](website/) |
| `/app/` | The Flutter web app | `lib/`, built with `--base-href /app/` |

Keeping the app on the same domain, under `/app/`, means one deployment, one
HTTPS certificate (the browser only allows the microphone over HTTPS), and the
landing page's **Open Suga in your browser** button is a plain link.
[`tool/build_site.sh`](tool/build_site.sh) assembles `build/site/` from both,
and [`vercel.json`](vercel.json) tells Vercel to run it. The web app is built
with `--no-web-resources-cdn` and bundles its fonts, so it never contacts
Google's CDNs.

`vercel.json` also sets the security headers. The microphone is blocked on the
landing pages and allowed only on `/app/` (`Permissions-Policy`), and the
landing pages get a strict Content Security Policy (no inline scripts).

### Test locally

[`tool/serve_site.py`](tool/serve_site.py) is a small preview server that reads
`vercel.json`, so `/privacy`, `/terms`, the redirects and the security headers
behave as they do on Vercel. It needs only Python 3 (built into macOS).

| To check | Run | Then open |
|---|---|---|
| Landing page, privacy, terms (fast, no build) | `python3 tool/serve_site.py website` | http://localhost:8000 |
| Everything as deployed, including the web app | `./tool/build_site.sh && python3 tool/serve_site.py` | http://localhost:8000 and http://localhost:8000/app/ |
| The app while changing Flutter code (hot reload) | `flutter run -d chrome` | opens by itself |

- In the first mode, edits to `website/` show on refresh. In the second, the
  site is a built copy in `build/site/`, so rerun `./tool/build_site.sh` after
  changes.
- Stop the server with **Ctrl+C**. Use `--port 9000` if 8000 is busy.
- Don't open the HTML files by double-clicking: pages use root paths like
  `/styles.css`, which point to your drive's root on `file://`.
- The microphone works on `localhost` without HTTPS. On a phone it needs
  HTTPS, so to try the web app on a real phone use a Vercel preview URL (see
  below) rather than your computer's LAN address.

### Deploy to Vercel

It's not the only way: there are three, and you pick **one**. The repo is set
up for **A**.

**A. One project, Vercel builds it** (recommended, already configured)

1. **Add New → Project**, import this repository. Framework preset: **Other**.
   Leave the root directory, build and output settings empty; `vercel.json`
   sets them.
2. **Settings → Domains → Add** `suga.shaunniekins.com`. At your DNS provider,
   add a `CNAME` record for `suga` pointing to `cname.vercel-dns.com` (Vercel
   shows the exact value).
3. Push to `main` to deploy to production. Every other branch or pull request
   gets its own **preview URL** (HTTPS, so it works for testing the web app
   on a phone).

Each build downloads the Flutter version pinned in `tool/build_site.sh` (keep
it in step with your local one), so a deploy takes a few minutes. Builds are
skipped when a commit only touches `android/`, `ios/`, `store/` or docs.

**B. Two projects: landing and app on separate subdomains**

Use this if you want the landing page to deploy in seconds, independently of
the app.

- *Landing* project: root directory `website`, preset **Other**, no build
  command, output directory `.`. Vercel reads `vercel.json` from the root
  directory, so copy the rewrites, redirects and landing-page headers into a
  new `website/vercel.json`.
- *App* project: this repository with build command
  `flutter build web --release --no-web-resources-cdn` and output
  `build/web`, on a domain such as `app.suga.shaunniekins.com`. It needs
  Flutter installed in its build (as `tool/build_site.sh` does) and the
  `/app/` headers from `vercel.json` (with `microphone=(self)`).
- Change the landing page's `/app/` links to the app's full URL.

More moving parts (two projects, two configs, two domains), which is why the
repo uses A.

**C. Build on your machine (or in CI) and upload the result**

Use this if Vercel's own build is too slow or fails. Vercel never installs
Flutter; it just hosts what you upload.

```sh
npm i -g vercel                                # once
vercel link                                    # once: connect this folder to the project
vercel pull --yes --environment=production     # fetch the project settings
vercel build --prod                            # runs tool/build_site.sh with your Flutter
vercel deploy --prebuilt --prod                # uploads .vercel/output
```

The same commands work in GitHub Actions with the `VERCEL_TOKEN`,
`VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` secrets. If you deploy this way,
turn off automatic Git deployments in the project settings so pushes don't
also trigger a Vercel build.

---

## Development

Requirements: Flutter 3.38+ (Dart 3.8+). Suga runs on **Android, iOS and the
web**. Android builds use Gradle 8.14, AGP 8.11 and Kotlin 2.2, matching
Flutter's current templates.

```sh
flutter pub get
flutter run                 # on a connected phone; the mic doesn't work on most emulators
flutter run -d chrome       # in the browser
flutter analyze
flutter test
```

### How it works

```
mic samples ──▶ AudioAnalyzer ──▶ AudioFrame (level, 24 bands, beat)
 (bursts)        FFT + auto gain        │  ~43 per second
                 + beat detection       ▼
                                  StageDirector ──▶ Stage ──▶ visualizer
                                  paces frames to     (smoothed values, beat
                                  the display, 60 fps  count, palette, spin)
```

Microphones deliver audio in bursts (~145 ms on Android, ~0.5 s on iOS, ~46 ms
on the web). `StageDirector` releases the analyzed frames at their real-time
pace so motion stays smooth, at the cost of about one burst of latency.

### Project layout

```
lib/
  main.dart                    App entry, theme, system UI mode
  app/theme.dart               UI colors, durations, ThemeData
  audio/
    fft.dart                   Radix-2 FFT with a Hann window
    audio_analyzer.dart        Samples → level, spectrum bands, beats
  visuals/
    palette.dart               Club palettes and the meter scale
    stage.dart                 Stage snapshot + StageDirector (pacing, smoothing)
  models/
    color_mode.dart            The eight modes, with label, icon, default order
    mode_lineup.dart           The user's order and on/off choice of modes
  services/
    microphone_audio*.dart     Raw mic samples: interface + device/web versions
    microphone_permission*.dart  Permission request: device/web versions
    mode_lineup_store.dart     Saves the lineup (shared_preferences)
  screens/
    home_screen.dart           Lamp button, permission flow, reveal transition
    visualizer_screen.dart     Ticker loop, controls, mic errors
  widgets/
    mode_switcher.dart         The mode pill (tap, swipe)
    mode_lineup_sheet.dart     Customize sheet: switch off and reorder modes
    visualizers/               One widget per mode
website/                       Landing page, privacy, terms (static HTML/CSS)
store/                         Store graphics and the listing checklist
tool/
  build_site.sh                Builds website + web app into build/site
  serve_site.py                Local preview with vercel.json's routes and headers
  store/generate.sh            Regenerates store and website images
```

### Store and website images

Screenshots, the Play feature graphic and the website's images are rendered
from the real app widgets driven by synthetic music, so they always match the
UI. After a noticeable UI change:

```sh
./tool/store/generate.sh     # needs cwebp: brew install webp
```

### Platform notes

- **Android:** `RECORD_AUDIO` is the only permission the release app requests
  (no internet access). App ID: `com.shaunniekins.suga`.
- **iOS:** `NSMicrophoneUsageDescription` is set in `ios/Runner/Info.plist`,
  and `ios/Podfile` defines `PERMISSION_MICROPHONE=1`. `permission_handler`
  always reports "denied" without that macro. Bundle ID:
  `com.shaunniekins.suga`. The app supports iPad, so App Store Connect needs
  iPad screenshots too.
- **Web:** the mic plugins are mobile-only, so the web build uses the
  browser's `getUserMedia` and Web Audio APIs instead (chosen by conditional
  imports). Browsers only allow the microphone on **HTTPS** pages or
  `localhost`. If someone blocks the mic, they unblock it from the address
  bar's site settings. Keeping the screen awake needs a browser that supports
  the Screen Wake Lock API.

---

## 📦 Releasing

1. **Bump the version** in `pubspec.yaml` only (`version: 1.0.0+1` → name
   `1.0.0`, build `1`). Android and iOS both read it from there. The `+build`
   number must go up on **every** store upload.
2. **Android signing:** release builds use the Play upload key from
   `android/key.properties` + its keystore (both git-ignored; keep backups
   outside the repo). Without them the build falls back to the debug key,
   which Play rejects. Create a key once with
   `keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`,
   then write `android/key.properties`:
   ```properties
   storePassword=…
   keyPassword=…
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
3. **Build:**
   ```bash
   flutter build appbundle --release   # Google Play: build/app/outputs/bundle/release/app-release.aab
   flutter build ipa --release         # App Store: then upload with Xcode or Transporter
   ```
   Check the bundle isn't debug-signed:
   `keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab`.
4. **Upload**, and update the [store listing](#️-store-listing) if features
   changed. The checklist for each store is in [`store/README.md`](store/README.md).

---

## Troubleshooting

**`Unresolved reference: filePermissions` in `FlutterPlugin.kt`.** The Android
Gradle setup is older than your Flutter SDK. This project uses the Kotlin DSL
files (`settings.gradle.kts`, `build.gradle.kts`) from Flutter's current
template. Don't pin Gradle, AGP or Kotlin to older versions. If it happens
after a Flutter upgrade, compare `android/` against a fresh `flutter create`
and run `flutter clean`.

**`MissingPluginException` on the web after adding a plugin.** The web build
kept a stale plugin list. Run `flutter clean`, then build again.

---

## 🤝 Community & Support

- ☕ **Buy Me a Coffee:** [buymeacoffee.com/shaunniekins](https://buymeacoffee.com/shaunniekins)
- ✉️ **Contact:** [contact@shaunniekins.com](mailto:contact@shaunniekins.com)
