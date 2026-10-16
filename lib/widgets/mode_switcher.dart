import 'package:flutter/material.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/models/color_mode.dart';

/// Pill showing the current mode; tapping it moves to the next one. The dots
/// show where the current mode sits in the cycle.
class ModeSwitcher extends StatelessWidget {
  const ModeSwitcher({super.key, required this.mode, required this.onPressed});

  final ColorMode mode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Color mode: ${mode.label}. Tap for ${mode.next.label}.',
      excludeSemantics: true,
      child: Material(
        color: SugaColors.scrim,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(mode.icon, size: 20, color: SugaColors.ice),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: SugaDurations.quick,
                    child: Text(
                      mode.label,
                      key: ValueKey(mode),
                      style: const TextStyle(
                        color: SugaColors.ice,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  for (final m in ColorMode.values)
                    AnimatedContainer(
                      duration: SugaDurations.quick,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: m == mode ? 14 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: m == mode ? SugaColors.signal : SugaColors.mist,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
