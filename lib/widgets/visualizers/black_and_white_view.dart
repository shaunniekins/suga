import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// Flips between black and white on each beat. With reduced motion on, it
/// fades through grays by loudness instead of flipping.
class BlackAndWhiteView extends StatelessWidget {
  const BlackAndWhiteView({super.key, required this.stage});

  final Stage stage;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final color = reduceMotion
        ? Color.lerp(Colors.black, Colors.white, stage.level)!
        : (stage.beats.isOdd ? Colors.white : Colors.black);
    return ColoredBox(color: color);
  }
}
