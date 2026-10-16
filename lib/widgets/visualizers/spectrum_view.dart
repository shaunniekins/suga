import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// Winamp-style spectrum analyzer: bars from bass to treble with falling
/// peak caps and a mirrored reflection. Bar colors rotate on every beat.
class SpectrumView extends StatelessWidget {
  const SpectrumView({super.key, required this.stage});

  final Stage stage;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _SpectrumPainter(stage));
  }
}

class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter(this.stage);

  final Stage stage;

  @override
  void paint(Canvas canvas, Size size) {
    final s = stage;
    final bands = s.bands.length;
    final baseline = size.height * 0.68;
    final maxHeight = baseline * 0.9;
    const sideMargin = 12.0;
    final slot = (size.width - sideMargin * 2) / bands;
    final barWidth = slot * 0.74;

    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    // Floor glow that flashes with each beat.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(0, (baseline / size.height) * 2 - 1),
          radius: 0.9,
          colors: [
            s.color(0).withValues(alpha: 0.12 + 0.3 * s.pulse),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );

    // One gradient across the full bar height, so color tells loudness.
    final barRect = Rect.fromLTRB(
      0,
      baseline - maxHeight,
      size.width,
      baseline,
    );
    final barPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [s.color(0), s.color(1), s.color(2)],
      ).createShader(barRect);
    final reflection = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              s.color(0).withValues(alpha: 0.35),
              s.color(0).withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromLTRB(0, baseline, size.width, baseline + maxHeight * 0.35),
          );
    final capPaint = Paint()
      ..color = Color.lerp(s.color(3), Colors.white, 0.5)!;

    for (var i = 0; i < bands; i++) {
      final left = sideMargin + i * slot + (slot - barWidth) / 2;
      final height = s.bands[i] * maxHeight;
      const radius = Radius.circular(3);

      canvas.drawRRect(
        RRect.fromLTRBR(
          left,
          baseline - height,
          left + barWidth,
          baseline,
          radius,
        ),
        barPaint,
      );
      canvas.drawRRect(
        RRect.fromLTRBR(
          left,
          baseline + 4,
          left + barWidth,
          baseline + 4 + height * 0.35,
          radius,
        ),
        reflection,
      );

      final capY = baseline - s.peaks[i] * maxHeight - 8;
      canvas.drawRRect(
        RRect.fromLTRBR(left, capY, left + barWidth, capY + 4, radius),
        capPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpectrumPainter oldDelegate) => true;
}
