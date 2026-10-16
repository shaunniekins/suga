import 'package:flutter/material.dart';
import 'package:suga/models/color_mode.dart';
import 'package:suga/visuals/stage.dart';
import 'package:suga/widgets/visualizers/assorted_view.dart';
import 'package:suga/widgets/visualizers/black_and_white_view.dart';
import 'package:suga/widgets/visualizers/disco_view.dart';
import 'package:suga/widgets/visualizers/gradient_view.dart';
import 'package:suga/widgets/visualizers/level_view.dart';
import 'package:suga/widgets/visualizers/pulse_view.dart';
import 'package:suga/widgets/visualizers/spectrum_view.dart';
import 'package:suga/widgets/visualizers/tiles_view.dart';

/// Renders [stage] in the style of [mode], filling all the space it's given.
class Visualizer extends StatelessWidget {
  const Visualizer({super.key, required this.mode, required this.stage});

  final ColorMode mode;
  final Stage stage;

  @override
  Widget build(BuildContext context) {
    // Some modes are a bare ColoredBox, which shrinks to nothing under loose
    // constraints (e.g. inside AnimatedSwitcher), so force them to fill.
    return SizedBox.expand(child: _view());
  }

  Widget _view() {
    return switch (mode) {
      ColorMode.disco => DiscoView(stage: stage),
      ColorMode.spectrum => SpectrumView(stage: stage),
      ColorMode.pulse => PulseView(stage: stage),
      ColorMode.assorted => AssortedView(stage: stage),
      ColorMode.blackAndWhite => BlackAndWhiteView(stage: stage),
      ColorMode.gradient => GradientView(stage: stage),
      ColorMode.tiles => TilesView(stage: stage),
      ColorMode.level => LevelView(stage: stage),
    };
  }
}
