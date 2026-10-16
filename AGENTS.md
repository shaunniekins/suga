# AGENTS.md

Guidance for coding agents working on Suga, a Flutter app (Android, iOS, web)
that turns microphone audio into Winamp-style, beat-reactive full-screen light. See `README.md` for features and project layout.

## Commands

```sh
flutter pub get
flutter analyze          # must report "No issues found!"
flutter test             # unit + widget tests in test/
dart format lib test
flutter build apk --debug  # verifies the Android Gradle setup
flutter build web          # verifies the web build (dart:js_interop code)
```

Run `analyze` and `test` before declaring a change done. Run the APK build after
any change under `android/` or to plugin dependencies, and the web build after
any change to a `*_web.dart` file or to dependencies.

## Architecture

Audio flows mic → `AudioAnalyzer` → `StageDirector` → `Stage` → visualizer.

- `audio/audio_analyzer.dart` is pure Dart: raw samples in, `AudioFrame`s
  (level, 24 log-spaced bands, beat flag) out. It owns the FFT, automatic gain
  and beat detection. Tune it with `test/audio_analyzer_test.dart`, which
  drives it with synthetic kick-drum tracks, not by guessing on a device.
- `visuals/stage.dart`: `StageDirector` paces bursty frames to the display
  clock, smooths values, counts beats and builds the `Stage` snapshot.
  `Stage.color(i)` rotates the palette on every beat; use it for any
  beat-reactive color.
- Platform code lives behind conditional imports in `services/`:
  `microphone_audio.dart` and `microphone_permission.dart` pick a
  `*_device.dart` (plugins) or `*_web.dart` (`package:web`) implementation.
  Each pair must export the same top-level API.
- `screens/visualizer_screen.dart` runs a `Ticker` that calls
  `director.advance` every frame. It also owns the mic subscription,
  wakelock, immersive mode and controls.
- Visualizers in `widgets/visualizers/` only take a `Stage` and draw. They
  usually use a `CustomPainter`. Detect a beat in `didUpdateWidget` by
  comparing `stage.beats` with the old widget's value. Use `stage.time` for
  animation, never wall-clock time.
- The modes the user cycles through come from `ModeLineup`
  (`models/mode_lineup.dart`): their order plus which are off, saved by
  `ModeLineupStore`. Step through modes with `lineup.step(mode, ±1)`, never
  `ColorMode.values`. A lineup always keeps at least one mode on.
- To add a mode: add a value to `ColorMode` (label + icon), a widget in
  `widgets/visualizers/`, and a case in `Visualizer`'s switch. Saved
  lineups pick up new modes automatically (appended, switched on).
  `test/widget_test.dart` loops over `ColorMode.values` automatically.
  Don't rename existing `ColorMode` values: saved lineups store their names.

## Rules

- **Photosensitivity:** full-screen hard color changes may only happen on
  beats. `AudioAnalyzer.minBeatGap` caps beats below 3 per second; don't
  lower it below 334 ms, and don't flash on anything other than a beat.
  Respect `MediaQuery.disableAnimationsOf` (the director's `calm` mode).
- **Colors and timing:** UI chrome uses `SugaColors` and `SugaDurations` in
  `lib/app/theme.dart`. Visualizers take colors from the stage (`Stage.color`,
  `Stage.dim`) or `visuals/palette.dart`. Don't hardcode new hex values in
  screens. If you change `SugaColors.night`, update
  `android/app/src/main/res/values/colors.xml` and `web/index.html` too.
- **Android build files** are the Kotlin DSL from Flutter's app template. Don't
  reintroduce Groovy `build.gradle` files or pin Gradle/AGP/Kotlin below the
  versions in `android/settings.gradle.kts` and the Gradle wrapper. On a
  Flutter upgrade, diff against a fresh `flutter create`.
- **iOS microphone** needs both `NSMicrophoneUsageDescription` (Info.plist) and
  `PERMISSION_MICROPHONE=1` (Podfile); keep them in sync with any new
  `permission_handler` permissions.
- **Dependencies:** `permission_handler` is held at 12 because
  `audio_streamer` 4 depends on `permission_handler ^12`. Upgrade both
  together.
- **Performance:** painters run every frame. Allocate nothing per band in
  hot loops beyond `Paint`/`Path`, and keep `AudioAnalyzer` allocation-light.
- **Platforms:** only Android, iOS and web are supported. Don't import
  `dart:io`, `audio_streamer` or `permission_handler` outside the
  `*_device.dart` files, or `package:web` outside the `*_web.dart` files.
- **App icon:** the source is `assets/icons/app_icon_source.png` (plus
  `app_icon_foreground.png` for Android's adaptive icon); the home screen's
  lamp shows the same file. After changing it, run
  `dart run flutter_launcher_icons` to regenerate the Android, iOS and web
  icons from the `flutter_launcher_icons` section of `pubspec.yaml`.
- **No `print`:** log with `dart:developer` `log(..., name: 'suga')`.
- The microphone doesn't work on most emulators; test audio behavior on a
  real device. For the web, Chrome's `--use-fake-device-for-media-stream
  --use-fake-ui-for-media-stream` flags feed a beeping test tone.
