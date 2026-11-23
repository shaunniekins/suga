---
title: "Music apps are opened, not embedded or controlled, and the mic restarts on return"
author: Shaunniekins
date: 2026-11-23
branch: feature/music-apps
cost: { minutes: 10, tokens: 82883 }
id: l-deda6f66
scope: repo
status: active
src: agent
touches:
  - lib/models/music_app.dart
  - lib/services/music_launcher.dart
  - lib/widgets/music_apps_sheet.dart
  - test/music_apps_test.dart
  - lib/screens/visualizer_screen.dart
---

## Decided
- "Play music" only launches Spotify, YouTube Music or Apple Music; the mic hears the song like any other sound. No SDK, sign-in or network, so "no account" and "Android app has no internet access" in the privacy policy and store copy stay true.
- On iOS launch the app's own scheme (`spotify:`, `youtubemusic://`, `music://`); on Android launch the https link with `LaunchMode.externalNonBrowserApplication`. Both return false when the app isn't installed (iOS `openURL` fails, Android catches ActivityNotFoundException), which drives the "Is it installed?" snack bar. No `LSApplicationQueriesSchemes` or `<queries>` needed because we never call `canLaunchUrl`.
- The visualizer cancels the mic subscription on `AppLifecycleListener.onHide` and re-listens on `onShow`. Re-listening to `audio_streamer`'s EventChannel restarts recording natively; without it iOS may not resume after the user comes back from the music app (the plugin removes its interruption observer on cancel and doesn't stop on background).
- On the web the launch must happen inside the tap (before the sheet's pop future resolves) or the browser blocks the new tab, so the sheet pops with `(app, launch(app))`.

## Tried and ruled out
- Spotify App Remote SDK: needs Premium, a Spotify developer app (limited to 25 users unless Spotify grants extended quota, which since 2025 goes only to large businesses) and a sign-in.
- YouTube Music has no public control API. Capturing other apps' audio is impossible: Spotify/YouTube Music opt out of Android playback capture, and iOS has no such API.
- Android system media controls (MediaSessionManager) need notification-listener access; declined as too invasive for this app.

## Watch out
- `audio_streamer` sets `playAndRecord` + `mixWithOthers` without `defaultToSpeaker`; on iPhone the other app's music may route to the earpiece while Suga listens. Unverified on a device.
- The website FAQ, `llms.txt` and store copy weren't updated: change them when a store build with the button ships, not before.

In the code: `lib/models/music_app.dart`, `lib/services/music_launcher.dart`, `lib/widgets/music_apps_sheet.dart`, `lib/screens/visualizer_screen.dart` (`_pause`/`_resume`), `test/music_apps_test.dart`.
