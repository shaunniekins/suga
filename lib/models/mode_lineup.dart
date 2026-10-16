import 'package:flutter/foundation.dart';
import 'package:suga/models/color_mode.dart';

/// The user's arrangement of modes: their order, and which ones are off.
///
/// Immutable; every change returns a new lineup. At least one mode always
/// stays on.
@immutable
class ModeLineup {
  ModeLineup({List<ColorMode>? order, Set<ColorMode> hidden = const {}})
    : order = List.unmodifiable(_complete(order ?? ColorMode.values)),
      hidden = Set.unmodifiable(
        hidden.containsAll(ColorMode.values) ? const <ColorMode>{} : hidden,
      );

  /// Rebuilds a lineup from saved mode names. Unknown names are dropped, and
  /// modes added since it was saved are appended, switched on.
  factory ModeLineup.fromNames({
    required List<String> order,
    required List<String> hidden,
  }) {
    final byName = ColorMode.values.asNameMap();
    return ModeLineup(
      order: [for (final name in order) ?byName[name]],
      hidden: {for (final name in hidden) ?byName[name]},
    );
  }

  /// Every mode, in [order], including hidden ones.
  final List<ColorMode> order;
  final Set<ColorMode> hidden;

  /// The modes the switcher cycles through, in order.
  List<ColorMode> get enabled => [
    for (final mode in order)
      if (!hidden.contains(mode)) mode,
  ];

  bool isEnabled(ColorMode mode) => !hidden.contains(mode);

  /// Whether [mode] can be switched off (it isn't the last one on).
  bool canHide(ColorMode mode) => isEnabled(mode) && enabled.length > 1;

  List<String> get orderNames => [for (final mode in order) mode.name];
  List<String> get hiddenNames => [for (final mode in hidden) mode.name];

  /// The enabled mode [step] places after [current] (negative for before),
  /// wrapping around. If [current] is off, counts from where it sits.
  ColorMode step(ColorMode current, int step) {
    final on = enabled;
    final index = on.indexOf(current);
    if (index != -1) return on[(index + step) % on.length];

    // Off: find the nearest enabled mode in that direction.
    final position = order.indexOf(current);
    for (var i = 1; i <= order.length; i++) {
      final candidate = order[(position + i * step.sign) % order.length];
      if (isEnabled(candidate)) return candidate;
    }
    return on.first;
  }

  ModeLineup toggled(ColorMode mode) {
    if (!isEnabled(mode)) {
      return ModeLineup(order: order, hidden: {...hidden}..remove(mode));
    }
    if (!canHide(mode)) return this;
    return ModeLineup(order: order, hidden: {...hidden, mode});
  }

  /// Moves the mode at [from] to [to], where [to] is an index in the list
  /// *before* the move (the convention `ReorderableListView.onReorder` uses).
  ModeLineup moved(int from, int to) {
    final reordered = [...order];
    final mode = reordered.removeAt(from);
    reordered.insert(to > from ? to - 1 : to, mode);
    return ModeLineup(order: reordered, hidden: hidden);
  }

  static List<ColorMode> _complete(List<ColorMode> order) => [
    ...{...order},
    for (final mode in ColorMode.values)
      if (!order.contains(mode)) mode,
  ];

  @override
  bool operator ==(Object other) =>
      other is ModeLineup &&
      listEquals(other.order, order) &&
      setEquals(other.hidden, hidden);

  @override
  int get hashCode => Object.hash(Object.hashAll(order), hidden.length);
}
