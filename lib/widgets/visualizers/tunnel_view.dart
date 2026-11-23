import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// A feedback tunnel: every moment's circular spectrum is left behind and
/// zooms outward, twisting as it goes, so the music leaves trails.
class TunnelView extends StatefulWidget {
  const TunnelView({super.key, required this.stage});

  final Stage stage;

  @override
  State<TunnelView> createState() => _TunnelViewState();
}

typedef _Ring = ({double born, List<double> bands, int color, double spin});

class _TunnelViewState extends State<TunnelView> {
  static const _life = 2.2;
  static const _every = 1 / 24;

  final List<_Ring> _rings = [];

  @override
  void didUpdateWidget(TunnelView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stage = widget.stage;
    if (_rings.isEmpty || stage.time - _rings.last.born >= _every) {
      _rings.add((
        born: stage.time,
        bands: stage.bands,
        color: stage.beats,
        spin: stage.spin,
      ));
    }
    _rings.removeWhere((ring) => stage.time - ring.born > _life);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _TunnelPainter(widget.stage, List.of(_rings), _life),
    );
  }
}

class _TunnelPainter extends CustomPainter {
  _TunnelPainter(this.stage, this.rings, this.life);

  final Stage stage;
  final List<_Ring> rings;
  final double life;

  @override
  void paint(Canvas canvas, Size size) {
    final s = stage;
    final center = size.center(Offset.zero);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    final start = size.shortestSide * 0.06;
    final reach = size.longestSide * 0.8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.plus;
    final colors = s.palette.colors;

    // Oldest (largest) first, so the newest rings sit on top.
    for (final ring in rings) {
      final age = ((s.time - ring.born) / life).clamp(0.0, 1.0);
      // Exponential growth reads as steady speed into the screen.
      final radius = start * pow(reach / start, age).toDouble();
      final twist = ring.spin * 0.5 + age * 1.4;
      paint
        ..strokeWidth = 1.5 + 4 * age
        ..color = colors[ring.color % colors.length].withValues(
          alpha: pow(1 - age, 1.4).toDouble() * 0.9,
        );
      canvas.drawPath(_ringPath(center, radius, twist, ring.bands), paint);
    }

    // The newest ring stays bright at the center, with a glow on the beat.
    canvas.drawCircle(
      center,
      start * (1.6 + 1.2 * s.pulse + s.bass),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.7),
            s.color(0).withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: start * 3)),
    );
  }

  /// A closed loop whose radius bulges with the (mirrored) spectrum.
  static Path _ringPath(
    Offset center,
    double radius,
    double twist,
    List<double> bands,
  ) {
    final count = bands.length * 2;
    final path = Path();
    for (var i = 0; i <= count; i++) {
      final k = i % count;
      final band = k < bands.length ? k : count - 1 - k;
      final r = radius * (1 + 0.35 * bands[band]);
      final angle = twist + k * 2 * pi / count;
      final point = center + Offset(cos(angle), sin(angle)) * r;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_TunnelPainter oldDelegate) => true;
}
