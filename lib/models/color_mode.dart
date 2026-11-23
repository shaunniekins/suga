import 'package:flutter/material.dart';

/// The ways Suga can turn sound into light, in their default order
/// (alphabetical by label; keep it that way when adding one). The
/// user's own order and choice live in `ModeLineup`.
enum ColorMode {
  assorted('Assorted', Icons.auto_awesome_rounded),
  blackAndWhite('Black & white', Icons.contrast_rounded),
  disco('Disco', Icons.nightlife_rounded),
  gradient('Gradient', Icons.gradient_rounded),
  kaleido('Kaleido', Icons.filter_vintage_rounded),
  level('Level', Icons.equalizer_rounded),
  pulse('Pulse', Icons.track_changes_rounded),
  scope('Scope', Icons.show_chart_rounded),
  spectrum('Spectrum', Icons.graphic_eq_rounded),
  starfield('Starfield', Icons.flare_rounded),
  tiles('Tiles', Icons.grid_view_rounded),
  tunnel('Tunnel', Icons.cyclone_rounded);

  const ColorMode(this.label, this.icon);

  final String label;
  final IconData icon;
}
