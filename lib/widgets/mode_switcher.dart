import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/models/color_mode.dart';

/// Pill showing the current mode. Tap or swipe right for the next mode,
/// swipe left for the previous one. The dots show where the current mode
/// sits among [modes].
class ModeSwitcher extends StatefulWidget {
  const ModeSwitcher({
    super.key,
    required this.mode,
    required this.modes,
    required this.onStep,
    this.direction = 1,
  });

  final ColorMode mode;

  /// The enabled modes, in cycling order.
  final List<ColorMode> modes;

  /// Called with +1 for next or −1 for previous.
  final ValueChanged<int> onStep;

  /// Direction of the last change, so the label slides the matching way.
  final int direction;

  @override
  State<ModeSwitcher> createState() => _ModeSwitcherState();
}

class _ModeSwitcherState extends State<ModeSwitcher> {
  /// A drag this far, or a fling this fast, counts as a swipe.
  static const _swipeDistance = 24.0;
  static const _swipeVelocity = 300.0;

  double _drag = 0;

  void _step(int step) {
    HapticFeedback.selectionClick();
    widget.onStep(step);
  }

  void _endDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() >= _swipeVelocity) {
      _step(velocity > 0 ? 1 : -1);
    } else if (_drag.abs() >= _swipeDistance) {
      _step(_drag > 0 ? 1 : -1);
    }
    _drag = 0;
  }

  ColorMode _neighbour(int step) {
    final modes = widget.modes;
    final index = modes.indexOf(widget.mode);
    return modes[(index + step) % modes.length];
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final single = widget.modes.length < 2;

    return Semantics(
      button: true,
      label: 'Color mode',
      value: mode.label,
      hint: single
          ? null
          : 'Tap or swipe right for ${_neighbour(1).label}, '
                'swipe left for ${_neighbour(-1).label}.',
      onIncrease: single ? null : () => _step(1),
      onDecrease: single ? null : () => _step(-1),
      increasedValue: single ? null : _neighbour(1).label,
      decreasedValue: single ? null : _neighbour(-1).label,
      excludeSemantics: true,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) => _drag += details.delta.dx,
        onHorizontalDragEnd: single ? null : _endDrag,
        child: Material(
          color: SugaColors.scrim,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: single ? null : () => _step(1),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SlidingLabel(mode: mode, direction: widget.direction),
                    if (!single) ...[
                      const SizedBox(width: 14),
                      for (final m in widget.modes)
                        AnimatedContainer(
                          duration: SugaDurations.quick,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          width: m == mode ? 14 : 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: m == mode
                                ? SugaColors.signal
                                : SugaColors.mist,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon and name of the mode. On a change the new one slides in from the
/// side the swipe came from, pushing the old one out.
class _SlidingLabel extends StatelessWidget {
  const _SlidingLabel({required this.mode, required this.direction});

  final ColorMode mode;
  final int direction;

  @override
  Widget build(BuildContext context) {
    final current = ValueKey(mode);
    return ClipRect(
      child: AnimatedSize(
        duration: SugaDurations.quick,
        child: AnimatedSwitcher(
          duration: SugaDurations.quick,
          transitionBuilder: (child, animation) {
            final incoming = child.key == current;
            final from = Offset((incoming ? -0.6 : 0.6) * direction, 0);
            return SlideTransition(
              position: Tween(begin: from, end: Offset.zero).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Row(
            key: current,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(mode.icon, size: 20, color: SugaColors.ice),
              const SizedBox(width: 10),
              Text(
                mode.label,
                style: const TextStyle(
                  color: SugaColors.ice,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
