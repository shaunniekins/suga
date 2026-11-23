---
title: "On Android, music apps must be listed in the manifest's queries or they show as not installed"
author: Shaunniekins
date: 2026-11-23
branch: feature/music-apps
cost: { minutes: 6, tokens: 31789 }
id: l-b8944f27
scope: repo
status: active
replaces: l-deda6f66
src: agent
touches:
  - android/app/src/main/AndroidManifest.xml
  - lib/models/music_app.dart
  - lib/screens/visualizer_screen.dart
  - lib/services/music_launcher.dart
---

## Decided
- Each Android package the Play music sheet opens (`com.spotify.music`, `com.google.android.apps.youtube.music`, `com.apple.android.music`) is listed under `<queries>` in the Android manifest. `LaunchMode.externalNonBrowserApplication` sets FLAG_ACTIVITY_REQUIRE_NON_BROWSER, and since Android 11 that resolution only considers apps the caller can see, so without the entry `startActivity` throws ActivityNotFoundException and Suga says "Is it installed?" for an installed app. Named packages, not QUERY_ALL_PACKAGES, which Play restricts.
- On return from the music app, re-apply immersive mode as well as restarting the mic: Android shows the system bars again.
- Everything else in the earlier learning stands (launch only, no SDK; iOS uses the app's URL scheme; mic stops on hide and re-listens on show).

## Tried and ruled out
- Debugging with `adb shell am start -f 0x400 -d https://music.youtube.com/`: it opens the app fine because the shell can see every package, which hides the visibility problem. Reproduce by tapping inside Suga instead.

In the code: `android/app/src/main/AndroidManifest.xml` (`<queries>`), `lib/models/music_app.dart`, `lib/services/music_launcher.dart`, `lib/screens/visualizer_screen.dart` (`_resume`).
