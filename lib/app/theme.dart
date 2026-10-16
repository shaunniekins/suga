import 'package:flutter/material.dart';

/// Palette drawn from the Suga logo: an ice-blue ribbon on slate.
abstract final class SugaColors {
  /// App background — the slate of a dark room. Mirrored in
  /// `android/app/src/main/res/values/colors.xml` for the launch screen.
  static const night = Color(0xFF0E161D);

  /// Raised slate, used where the logo sits.
  static const slate = Color(0xFF1C2B37);

  /// Primary text.
  static const ice = Color(0xFFE6EEF4);

  /// Secondary text (≈7:1 on [night]).
  static const mist = Color(0xFF93A7B6);

  /// The logo's blue; used for glow and focus.
  static const signal = Color(0xFF4DA3F0);

  /// Translucent backing for controls floating over the visualizer.
  static const scrim = Color(0xB30E161D);
}

abstract final class SugaDurations {
  static const quick = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const reveal = Duration(milliseconds: 560);
  static const breathe = Duration(milliseconds: 2400);
}

ThemeData buildSugaTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: SugaColors.signal,
        brightness: Brightness.dark,
      ).copyWith(
        primary: SugaColors.signal,
        surface: SugaColors.night,
        onSurface: SugaColors.ice,
        onSurfaceVariant: SugaColors.mist,
      );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: SugaColors.night,
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: SugaColors.slate,
      contentTextStyle: TextStyle(color: SugaColors.ice, fontSize: 15),
      actionTextColor: SugaColors.signal,
    ),
  );
}
