import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// The waveform bent into a circle and mirrored into twelve slices, like a
/// kaleidoscope, with the spectrum blooming inside it.
class KaleidoView extends StatelessWidget {
  const KaleidoView({super.key, required this.stage});

  final Stage stage;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _KaleidoPainter(stage));
  }
}

class _KaleidoPainter extends CustomPainter {
  _KaleidoPainter(this.stage);

  final Stage stage;

  static const _slices = 6;
  static const _sliceAngle = pi / _slices;

  @override
  void paint(Canvas canvas, Size size) {
    final s = stage;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.42;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader =
            RadialGradient(
              colors: [s.dim(2, 0.7 - 0.25 * s.pulse), Colors.black],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.longestSide * 0.7),
            ),
    );

    final wave = s.wave.isEmpty ? const [0.0, 0.0] : s.wave;
    final outer = _slice(wave.length, (i) => radius * (0.72 + 0.26 * wave[i]));
    final inner = _slice(
      s.bands.length,
      (i) => radius * (0.18 + 0.42 * s.bands[i]),
    );

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(s.spin * 0.3);
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.plus;

    for (var k = 0; k < _slices * 2; k++) {
      canvas.save();
      // Every other slice is mirrored about its far edge, so it fills the
      // next gap and neighbours meet seamlessly.
      canvas.rotate((k.isOdd ? k + 1 : k) * _sliceAngle);
      if (k.isOdd) canvas.scale(1, -1);
      canvas
        ..drawPath(
          outer,
          glow
            ..strokeWidth = 8 + 10 * s.pulse
            ..color = s.color(0).withValues(alpha: 0.5),
        )
        ..drawPath(
          outer,
          line
            ..strokeWidth = 2.5
            ..color = Color.lerp(s.color(0), Colors.white, 0.4)!,
        )
        ..drawPath(
          inner,
          line
            ..strokeWidth = 2 + 2 * s.level
            ..color = s.color(2).withValues(alpha: 0.85),
        );
      canvas.restore();
    }
    canvas.restore();
  }

  /// One slice's curve: [count] points spread over [_sliceAngle], at the
  /// distance [radiusOf] gives each.
  static Path _slice(int count, double Function(int) radiusOf) {
    final path = Path();
    for (var i = 0; i < count; i++) {
      final angle = _sliceAngle * i / max(1, count - 1);
      final r = radiusOf(i);
      final point = Offset(cos(angle), sin(angle)) * r;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(_KaleidoPainter oldDelegate) => true;
}
