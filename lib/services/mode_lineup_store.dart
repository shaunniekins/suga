import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:suga/models/mode_lineup.dart';

/// Saves the mode lineup on the device (local storage on the web).
class ModeLineupStore {
  static const _orderKey = 'modes.order';
  static const _hiddenKey = 'modes.hidden';

  /// The saved lineup, or the default one if nothing is saved or storage
  /// isn't available (e.g. a private browser window).
  Future<ModeLineup> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final order = prefs.getStringList(_orderKey);
      if (order == null) return ModeLineup();
      return ModeLineup.fromNames(
        order: order,
        hidden: prefs.getStringList(_hiddenKey) ?? const [],
      );
    } on Exception catch (error) {
      developer.log('Mode lineup unavailable', name: 'suga', error: error);
      return ModeLineup();
    }
  }

  Future<void> save(ModeLineup lineup) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_orderKey, lineup.orderNames);
      await prefs.setStringList(_hiddenKey, lineup.hiddenNames);
    } on Exception catch (error) {
      developer.log('Mode lineup not saved', name: 'suga', error: error);
    }
  }
}
