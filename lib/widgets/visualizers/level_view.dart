import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suga/visuals/palette.dart';
import 'package:suga/visuals/stage.dart';

/// A full-screen LED level meter with a falling peak marker.
class LevelView extends StatefulWidget {
  const LevelView({super.key, required this.stage});

  final Stage stage;

  @override
  State<LevelView> createState() => _LevelViewState();
}

class _LevelViewState extends State<LevelView> {
  static const _peakFallPerSecond = 0.45;

  double _peak = 0;

  @override
  void didUpdateWidget(LevelView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dt = (widget.stage.time - oldWidget.stage.time).clamp(0.0, 0.1);
    _peak = max(widget.stage.level, _peak - _peakFallPerSecond * dt);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF05080B),
      child: CustomPaint(
        size: Size.infinite,
        painter: _MeterPainter(level: widget.stage.level, peak: _peak),
      ),
    );
  }
}

class _MeterPainter extends CustomPainter {
  _MeterPainter({required this.level, required this.peak});

  static const _segmentHeight = 28.0;
  static const _gap = 6.0;

  final double level;
  final double peak;

  @override
  void paint(Canvas canvas, Size size) {
    final count = max(1, (size.height / _segmentHeight).floor());
    final height = size.height / count;
    final lit = (level * count).round();
    final peakIndex = (peak * count).round() - 1;
    final paint = Paint();

    // Segment 0 is at the bottom.
    for (var i = 0; i < count; i++) {
      final color = colorAt(meterSpectrum, i / max(1, count - 1));
      final on = i < lit || (i == peakIndex && i > 0);
      paint.color = on ? color : color.withValues(alpha: 0.08);

      final top = size.height - (i + 1) * height;
      final rect = Rect.fromLTWH(
        _gap * 2,
        top + _gap / 2,
        size.width - _gap * 4,
        height - _gap,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MeterPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.peak != peak;
}
