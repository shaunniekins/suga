---
title: "The default mode order is alphabetical, and untouched saved orders follow it"
author: Shaunniekins
date: 2026-11-23
branch: feature/music-apps
cost: { minutes: 5, tokens: 27393 }
id: l-fd00775f
scope: repo
status: active
src: agent
touches:
  - lib/models/color_mode.dart
  - lib/models/mode_lineup.dart
  - test/mode_lineup_test.dart
---

## Decided
- Modes default to alphabetical order by label (the order of `ColorMode`), at the user's request.
- Saved lineups store mode names in order, so changing the default alone does nothing for anyone who ever opened Customize: their saved copy of the old default wins. `ModeLineup.fromNames` treats a saved order as untouched when it is a former default with only newer modes appended after it (what the app saves once new modes exist). It then uses the current default and keeps just the on/off choices. A rearranged order is kept.

## Watch out
- Before changing `ColorMode`'s order again, add the current one to `ModeLineup._formerDefaults`.
- Tests should take neighbours from `ColorMode.values`, not hardcode modes, or every reorder breaks them.

In the code: `lib/models/color_mode.dart`, `lib/models/mode_lineup.dart` (`_formerDefaults`, `fromNames`), `test/mode_lineup_test.dart`.
