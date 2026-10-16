import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// Club lights: colored beams sweep from the center, mirror-ball sparkles
/// drift past, and the room flashes the next color on every beat.
class DiscoView extends StatelessWidget {
  const DiscoView({super.key, required this.stage});

  final Stage stage;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _DiscoPainter(stage));
  }
}

class _DiscoPainter extends CustomPainter {
  _DiscoPainter(this.stage);

  static const _beams = 8;
  static const _sparkles = 48;
  static final _sparkleSeeds = List.generate(_sparkles, (i) {
    final random = Random(i * 7919);
    return (
      angle: random.nextDouble() * 2 * pi,
      distance: 0.15 + random.nextDouble() * 0.85,
      phase: random.nextDouble() * 2 * pi,
      speed: 2 + random.nextDouble() * 5,
      band: random.nextInt(1 << 16),
    );
  });

  final Stage stage;

  @override
  void paint(Canvas canvas, Size size) {
    final s = stage;
    final center = size.center(Offset.zero);
    final reach = size.longestSide;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = s.dim(0, 0.88 - 0.4 * s.pulse - 0.1 * s.bass),
    );

    final additive = Paint()..blendMode = BlendMode.plus;

    // Beams: each follows its own slice of the spectrum.
    for (var i = 0; i < _beams; i++) {
      final band = s.bands[(i * s.bands.length ~/ _beams)];
      final width = 0.12 + 0.16 * band;
      final angle = s.spin * (i.isEven ? 1 : -0.7) + i * 2 * pi / _beams;
      final strength = (0.25 + 0.6 * band + 0.3 * s.pulse).clamp(0.0, 1.0);
      final color = s.color(i);

      final beam = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: reach),
          angle - width / 2,
          width,
          false,
        )
        ..close();
      additive.shader = RadialGradient(
        colors: [
          color.withValues(alpha: strength),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: reach * 0.9));
      canvas.drawPath(beam, additive);
    }

    // Mirror-ball sparkles, orbiting slowly and twinkling with the treble.
    additive.shader = null;
    final treble = s.bands.skip(s.bands.length * 2 ~/ 3);
    final shimmer = treble.fold(0.0, (a, b) => a + b) / treble.length;
    for (var i = 0; i < _sparkles; i++) {
      final seed = _sparkleSeeds[i];
      final twinkle = 0.5 + 0.5 * sin(s.time * seed.speed + seed.phase);
      final alpha = (twinkle * (0.2 + 0.8 * shimmer)).clamp(0.0, 1.0);
      if (alpha < 0.05) continue;
      final angle = seed.angle + s.spin * 0.35;
      final position =
          center + Offset(cos(angle), sin(angle)) * seed.distance * reach * 0.6;
      additive.color = Color.lerp(
        Colors.white,
        s.color(seed.band),
        0.4,
      )!.withValues(alpha: alpha);
      canvas.drawCircle(position, 2 + 3 * twinkle, additive);
    }

    // The light source, breathing with the bass.
    final glow = 30 + 90 * s.bass + 40 * s.pulse;
    canvas.drawCircle(
      center,
      glow,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, s.color(2).withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: glow)),
    );
  }

  @override
  bool shouldRepaint(_DiscoPainter oldDelegate) => true;
}
