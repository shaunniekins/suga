import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// Jumps to a new random hue on each beat; brightness follows loudness.
class AssortedView extends StatefulWidget {
  const AssortedView({super.key, required this.stage});

  final Stage stage;

  @override
  State<AssortedView> createState() => _AssortedViewState();
}

class _AssortedViewState extends State<AssortedView> {
  final _random = Random();
  double _hue = 207;

  @override
  void didUpdateWidget(AssortedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stage.beats != oldWidget.stage.beats) {
      // At least a third of the way round the wheel, so every beat reads.
      _hue = (_hue + 120 + _random.nextDouble() * 120) % 360;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stage;
    final brightness = (0.2 + 0.6 * s.level + 0.2 * s.pulse).clamp(0.0, 1.0);
    return ColoredBox(
      color: HSVColor.fromAHSV(1, _hue, 0.85, brightness).toColor(),
    );
  }
}
