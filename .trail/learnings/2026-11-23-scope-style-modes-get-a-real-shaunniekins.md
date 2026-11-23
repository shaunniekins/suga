---
title: "Scope-style modes get a real waveform from the analyzer, and the screen-reader check avoids MediaQuery"
author: Shaunniekins
date: 2026-11-23
branch: feature/music-apps
cost: { minutes: 8, tokens: 95443 }
id: l-b6bdc149
scope: repo
status: active
src: agent
touches:
  - README.md
  - android/app/src/main/AndroidManifest.xml
  - lib/models/music_app.dart
  - lib/screens/visualizer_screen.dart
  - lib/services/music_launcher.dart
  - lib/widgets/music_apps_sheet.dart
  - pubspec.lock
  - pubspec.yaml
  - test/music_apps_test.dart
  - lib/widgets/visualizers/scope_view.dart
---

## Decided
- Waveform modes (Scope, Kaleido) use a real 64-point waveform added to `AudioFrame.wave` / `Stage.wave`, not a wave faked from the spectrum bands. Each point averages 16 samples (a gentle low-pass, so the line doesn't fizz) and is scaled by the same automatic gain as `level` (crest factor 3), so quiet and loud rooms both fill the scope. `wave` defaults to empty so older callers and tests still build; views must handle an empty wave.
- The controls stay up while a screen reader is on. `_showControls` runs in `initState`, where `MediaQuery.accessibleNavigationOf` throws, so it reads `platformDispatcher.accessibilityFeatures.accessibleNavigation` instead.

## Watch out
- Kaleido mirrors alternate slices: an odd slice must rotate by (k+1)·π/6 before flipping, or it folds back over its neighbour and leaves gaps.
- The store copy and website still say "eight modes"; update them when a store build with the new modes ships.

In the code: `lib/audio/audio_analyzer.dart` (`wavePoints`, `_crestFactor`), `lib/visuals/stage.dart`, `lib/widgets/visualizers/kaleido_view.dart`, `lib/screens/visualizer_screen.dart` (`_screenReaderOn`).
