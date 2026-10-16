import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// Rings burst outward on every beat around a spinning circular spectrum.
class PulseView extends StatefulWidget {
  const PulseView({super.key, required this.stage});

  final Stage stage;

  @override
  State<PulseView> createState() => _PulseViewState();
}

typedef _Ring = ({double born, int color});

class _PulseViewState extends State<PulseView> {
  static const _ringLife = 1.4;

  final List<_Ring> _rings = [];

  @override
  void didUpdateWidget(PulseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stage = widget.stage;
    if (stage.beats != oldWidget.stage.beats) {
      _rings.add((born: stage.time, color: stage.beats));
    }
    _rings.removeWhere((ring) => stage.time - ring.born > _ringLife);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _PulsePainter(widget.stage, List.of(_rings), _ringLife),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.stage, this.rings, this.ringLife);

  final Stage stage;
  final List<_Ring> rings;
  final double ringLife;

  @override
  void paint(Canvas canvas, Size size) {
    final s = stage;
    final center = size.center(Offset.zero);
    final reach = size.longestSide * 0.75;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [s.dim(0, 0.75 - 0.3 * s.pulse), Colors.black],
        ).createShader(Rect.fromCircle(center: center, radius: reach)),
    );

    // Rings start at the core and just clear the screen's corners.
    final ringStart = size.shortestSide * 0.16;
    final ringTravel = size.longestSide * 0.6;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.plus;
    for (final ring in rings) {
      final age = ((s.time - ring.born) / ringLife).clamp(0.0, 1.0);
      final eased = 1 - pow(1 - age, 2).toDouble();
      ringPaint
        ..strokeWidth = 4 + 26 * (1 - age)
        ..color = s.palette.colors[ring.color % s.palette.colors.length]
            .withValues(alpha: 1 - age);
      canvas.drawCircle(center, ringStart + eased * ringTravel, ringPaint);
    }

    // Circular spectrum, mirrored so it's symmetrical.
    final radius = size.shortestSide * (0.16 + 0.06 * s.bass + 0.04 * s.pulse);
    final maxSpike = size.shortestSide * 0.3;
    final count = s.bands.length * 2;
    final spikePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = max(3, 2 * pi * radius / count * 0.55)
      ..blendMode = BlendMode.plus;
    for (var i = 0; i < count; i++) {
      final band = i < s.bands.length ? i : count - 1 - i;
      final value = s.bands[band];
      final angle = s.spin * 0.4 + i * 2 * pi / count;
      final direction = Offset(cos(angle), sin(angle));
      spikePaint.color = s.color(band % 5).withValues(alpha: 0.5 + 0.5 * value);
      canvas.drawLine(
        center + direction * radius,
        center + direction * (radius + 6 + value * maxSpike),
        spikePaint,
      );
    }

    canvas.drawCircle(
      center,
      radius * 0.78,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, s.color(1), s.dim(1, 0.6)],
          stops: const [0, 0.35, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) => true;
}
