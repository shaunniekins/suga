import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// The classic oscilloscope: the live waveform as a glowing line across a
/// dark screen, with fading copies behind it like a phosphor tube.
class ScopeView extends StatefulWidget {
  const ScopeView({super.key, required this.stage});

  final Stage stage;

  @override
  State<ScopeView> createState() => _ScopeViewState();
}

class _ScopeViewState extends State<ScopeView> {
  static const _trail = 6;
  static const _trailEvery = 1 / 30;

  /// Recent waveforms, newest last.
  final List<List<double>> _history = [];
  double _lastSample = double.negativeInfinity;

  @override
  void didUpdateWidget(ScopeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stage = widget.stage;
    if (stage.wave.isEmpty || stage.time - _lastSample < _trailEvery) return;
    _lastSample = stage.time;
    _history.add(stage.wave);
    if (_history.length > _trail) _history.removeAt(0);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ScopePainter(widget.stage, List.of(_history)),
    );
  }
}

class _ScopePainter extends CustomPainter {
  _ScopePainter(this.stage, this.history);

  final Stage stage;
  final List<List<double>> history;

  @override
  void paint(Canvas canvas, Size size) {
    final s = stage;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    // A faint graticule, like the screen of a bench scope.
    final grid = Paint()
      ..color = s.dim(3, 0.88)
      ..strokeWidth = 1;
    const divisions = 8;
    for (var i = 1; i < divisions; i++) {
      final x = size.width * i / divisions;
      final y = size.height * i / divisions;
      canvas
        ..drawLine(Offset(x, 0), Offset(x, size.height), grid)
        ..drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final amplitude = size.height * 0.36;
    final shader = LinearGradient(
      colors: [s.color(0), s.color(1), s.color(2), s.color(3)],
    ).createShader(Offset.zero & size);

    for (var h = 0; h < history.length; h++) {
      final age = (history.length - h) / (history.length + 1);
      canvas.drawPath(
        _wavePath(history[h], size, amplitude),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = s.color(h).withValues(alpha: 0.35 * (1 - age)),
      );
    }

    final wave = s.wave.isEmpty ? const [0.0, 0.0] : s.wave;
    final path = _wavePath(wave, size, amplitude);
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = shader
      ..blendMode = BlendMode.plus;
    canvas
      ..drawPath(
        path,
        glow
          ..strokeWidth = 14 + 18 * s.pulse
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 3 + 3 * s.pulse
          ..color = Color.lerp(s.color(1), Colors.white, 0.55)!,
      );
  }

  /// A smooth line through [wave], spread across the full width.
  static Path _wavePath(List<double> wave, Size size, double amplitude) {
    final mid = size.height / 2;
    final step = size.width / max(1, wave.length - 1);
    Offset point(int i) => Offset(i * step, mid - wave[i] * amplitude);

    final path = Path()..moveTo(0, point(0).dy);
    for (var i = 1; i < wave.length; i++) {
      final previous = point(i - 1);
      final current = point(i);
      final middle = (previous + current) / 2;
      path.quadraticBezierTo(previous.dx, previous.dy, middle.dx, middle.dy);
    }
    final last = point(wave.length - 1);
    return path..lineTo(last.dx, last.dy);
  }

  @override
  bool shouldRepaint(_ScopePainter oldDelegate) => true;
}
