import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// Flying through stars: they stream out of the center, faster when it's
/// louder, and surge forward on every beat.
class StarfieldView extends StatefulWidget {
  const StarfieldView({super.key, required this.stage});

  final Stage stage;

  @override
  State<StarfieldView> createState() => _StarfieldViewState();
}

class _StarfieldViewState extends State<StarfieldView> {
  static const _count = 340;
  static const _nearest = 0.04;

  final _random = Random(7);
  final _x = Float64List(_count);
  final _y = Float64List(_count);
  final _z = Float64List(_count);

  /// How far each star moved toward the viewer this frame (for streaks).
  double _travel = 0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _count; i++) {
      _spawn(i, _nearest + _random.nextDouble() * (1 - _nearest));
    }
  }

  void _spawn(int i, double z) {
    _x[i] = _random.nextDouble() * 2 - 1;
    _y[i] = _random.nextDouble() * 2 - 1;
    _z[i] = z;
  }

  @override
  void didUpdateWidget(StarfieldView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stage = widget.stage;
    final dt = (stage.time - oldWidget.stage.time).clamp(0.0, 0.1);
    final speed = 0.12 + 0.9 * stage.level + 1.6 * stage.pulse;
    _travel = speed * dt;
    for (var i = 0; i < _count; i++) {
      _z[i] -= _travel;
      if (_z[i] <= _nearest) _spawn(i, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _StarfieldPainter(widget.stage, _x, _y, _z, _travel),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter(this.stage, this.x, this.y, this.z, this.travel);

  final Stage stage;
  final Float64List x;
  final Float64List y;
  final Float64List z;
  final double travel;

  @override
  void paint(Canvas canvas, Size size) {
    final s = stage;
    final center = size.center(Offset.zero);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader =
            RadialGradient(
              colors: [s.dim(4, 0.82 - 0.1 * s.bass), Colors.black],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.longestSide * 0.6),
            ),
    );

    final scale = size.longestSide * 0.5;
    // Streaks are drawn at least this long, so stars read as moving.
    final streak = max(travel, 0.004);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus;

    for (var i = 0; i < x.length; i++) {
      final depth = z[i];
      final head = center + Offset(x[i], y[i]) * (scale / depth);
      final tail = center + Offset(x[i], y[i]) * (scale / (depth + streak));
      final nearness = 1 - depth;
      paint
        ..strokeWidth = 1.4 + 3.6 * nearness * nearness
        ..color = Color.lerp(
          s.color(i % 5),
          Colors.white,
          0.6,
        )!.withValues(alpha: (0.45 + 0.55 * nearness).clamp(0.0, 1.0));
      canvas.drawLine(tail, head, paint);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter oldDelegate) => true;
}
