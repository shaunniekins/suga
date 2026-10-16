import 'package:flutter/material.dart';

/// The ways Suga can turn sound into light, in their default order. The
/// user's own order and choice live in `ModeLineup`.
enum ColorMode {
  disco('Disco', Icons.nightlife_rounded),
  spectrum('Spectrum', Icons.graphic_eq_rounded),
  pulse('Pulse', Icons.track_changes_rounded),
  assorted('Assorted', Icons.auto_awesome_rounded),
  blackAndWhite('Black & white', Icons.contrast_rounded),
  gradient('Gradient', Icons.gradient_rounded),
  tiles('Tiles', Icons.grid_view_rounded),
  level('Level', Icons.equalizer_rounded);

  const ColorMode(this.label, this.icon);

  final String label;
  final IconData icon;
}
