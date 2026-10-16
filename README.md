# Suga

Suga (Cebuano for "light") turns the sound around you into light. Play music
and it listens through your microphone, finds the beat, and fills the screen
with color that moves with it, like a Winamp visualizer for the whole room.

## Features

- **Hears the beat.** Suga analyzes the microphone the way old Winamp
  visualizers did: a frequency spectrum (bass to treble), loudness with
  automatic gain (quiet background music and a loud party both use the full
  range), and beat detection on kicks and claps. Audio is never recorded or
  stored.
- **Every beat changes the light.** Colors come from club palettes (Neon,
  Sunset, Acid, Ocean, Fire) that shift one step on every beat. Every 16 beats
  the next palette takes over.
- **Eight modes.** Tap the mode pill at the bottom of the screen to cycle:
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
- **Immersive and awake.** The visualizer hides the system bars and keeps the
  screen on. Tap anywhere to show or hide the controls.
- **Photosensitivity-safe.** Beats are capped below three per second (WCAG
  2.3.1), so full-screen flashes never exceed that rate. With the system
  "remove animations" setting on, beats stop flashing and rotation slows.

## Using Suga

1. Tap the glowing logo on the home screen.
2. Allow microphone access when asked. If you've blocked it before, Suga
   offers a shortcut to the app's settings.
3. Play music or make some noise. Music with a clear kick drum gives the
   strongest beats.
4. Tap the screen to show the controls, tap the mode pill to switch modes,
   and tap **×** or go back to stop.

## Development

Requirements: Flutter 3.38+ (Dart 3.8+). Suga runs on **Android, iOS and the
web**. Android builds use Gradle 8.14, AGP 8.11 and Kotlin 2.2, matching
Flutter's current templates.

```sh
flutter pub get
flutter run                 # on a connected phone; the mic doesn't work on most emulators
flutter run -d chrome       # in the browser
flutter build web           # static site in build/web (add --wasm for WebAssembly)
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
on the web).
`StageDirector` releases the analyzed frames at their real-time pace so motion
stays smooth, at the cost of about one burst of latency.

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
  models/color_mode.dart       The eight modes, with label, icon, cycling order
  services/
    microphone_audio*.dart     Raw mic samples: interface + device/web versions
    microphone_permission*.dart  Permission request: device/web versions
  screens/
    home_screen.dart           Lamp button, permission flow, reveal transition
    visualizer_screen.dart     Ticker loop, controls, mic errors
  widgets/
    mode_switcher.dart         The mode pill
    visualizers/               One widget per mode
```

### Platform notes

- **Android:** `RECORD_AUDIO` is declared in `AndroidManifest.xml`.
- **iOS:** `NSMicrophoneUsageDescription` is set in `ios/Runner/Info.plist`,
  and `ios/Podfile` defines `PERMISSION_MICROPHONE=1`. `permission_handler`
  always reports "denied" without that macro.
- **Web:** the mic plugins are mobile-only, so the web build uses the
  browser's `getUserMedia` and Web Audio APIs instead (chosen by conditional
  imports). Browsers only allow the microphone on **HTTPS** pages or
  `localhost`, so host the build over HTTPS. If someone blocks the mic, they
  unblock it from the address bar's site settings. Keeping the screen awake
  needs a browser that supports the Screen Wake Lock API.

### Troubleshooting

**`Unresolved reference: filePermissions` in `FlutterPlugin.kt`.** The Android
Gradle setup is older than your Flutter SDK. This project uses the Kotlin DSL
files (`settings.gradle.kts`, `build.gradle.kts`) from Flutter's current
template. Don't pin Gradle, AGP or Kotlin to older versions. If it happens
after a Flutter upgrade, compare `android/` against a fresh `flutter create`
and run `flutter clean`.
