import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// A radial glow in the palette's current color that swells with loudness
/// and kicks outward on each beat.
class GradientView extends StatelessWidget {
  const GradientView({super.key, required this.stage});

  final Stage stage;

  @override
  Widget build(BuildContext context) {
    final s = stage;
    final core = Color.lerp(s.color(0), Colors.white, 0.15 * s.pulse)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.5 + 0.6 * s.level + 0.3 * s.pulse,
          colors: [core, s.dim(1, 0.55), Colors.black],
          stops: const [0, 0.6, 1],
        ),
      ),
    );
  }
}
