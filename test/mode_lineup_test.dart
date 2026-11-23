import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/models/color_mode.dart';
import 'package:suga/models/mode_lineup.dart';
import 'package:suga/services/mode_lineup_store.dart';
import 'package:suga/widgets/mode_lineup_sheet.dart';
import 'package:suga/widgets/mode_switcher.dart';

/// The default order, so tests don't depend on which mode comes where.
final modes = ColorMode.values;

void main() {
  group('ModeLineup', () {
    test('defaults to every mode, in order, all on', () {
      final lineup = ModeLineup();
      expect(lineup.enabled, ColorMode.values);
    });

    test('steps forward and back through enabled modes, wrapping', () {
      final lineup = ModeLineup(hidden: {modes[1], modes.last});
      expect(lineup.step(modes[0], 1), modes[2]);
      expect(lineup.step(modes[2], -1), modes[0]);
      final last = modes[modes.length - 2];
      expect(lineup.step(modes[0], -1), last);
      expect(lineup.step(last, 1), modes[0]);
    });

    test('steps from a hidden mode to its nearest enabled neighbour', () {
      final lineup = ModeLineup(hidden: {modes[1]});
      expect(lineup.step(modes[1], 1), modes[2]);
      expect(lineup.step(modes[1], -1), modes[0]);
    });

    test('never hides the last enabled mode', () {
      var lineup = ModeLineup();
      for (final mode in ColorMode.values) {
        lineup = lineup.toggled(mode);
      }
      expect(lineup.enabled, [ColorMode.values.last]);
      expect(lineup.canHide(ColorMode.values.last), isFalse);
      expect(lineup.toggled(ColorMode.values.last), lineup);
    });

    test('moves modes using ReorderableListView indices', () {
      final down = ModeLineup().moved(0, 3);
      expect(down.order.take(3), [modes[1], modes[2], modes[0]]);
      final up = ModeLineup().moved(2, 0);
      expect(up.order.first, modes[2]);
    });

    test('an order saved before the default changed follows the new one', () {
      final lineup = ModeLineup.fromNames(
        order: [
          'disco',
          'spectrum',
          'pulse',
          'assorted',
          'blackAndWhite',
          'gradient',
          'tiles',
          'level',
        ],
        hidden: ['tiles'],
      );
      expect(lineup.order, ColorMode.values);
      expect(lineup.hidden, {ColorMode.tiles});
    });

    test('so does a former default with newer modes appended', () {
      final lineup = ModeLineup.fromNames(
        order: [
          'disco',
          'spectrum',
          'pulse',
          'assorted',
          'blackAndWhite',
          'gradient',
          'tiles',
          'level',
          'scope',
          'starfield',
          'tunnel',
          'kaleido',
        ],
        hidden: const [],
      );
      expect(lineup.order, ColorMode.values);
    });

    test('a rearranged order is kept', () {
      final lineup = ModeLineup.fromNames(
        order: ['level', 'disco', 'spectrum'],
        hidden: const [],
      );
      expect(lineup.order.take(3), [
        ColorMode.level,
        ColorMode.disco,
        ColorMode.spectrum,
      ]);
    });

    test('restores from names, dropping unknown and adding new modes', () {
      final lineup = ModeLineup.fromNames(
        order: ['level', 'gone', 'disco'],
        hidden: ['disco', 'alsoGone'],
      );
      expect(lineup.order.take(2), [ColorMode.level, ColorMode.disco]);
      expect(lineup.order.toSet(), ColorMode.values.toSet());
      expect(lineup.hidden, {ColorMode.disco});
    });

    test('ignores saved data that hides everything', () {
      final lineup = ModeLineup.fromNames(
        order: const [],
        hidden: [for (final m in ColorMode.values) m.name],
      );
      expect(lineup.enabled, ColorMode.values);
    });
  });

  test('ModeLineupStore round-trips a lineup', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ModeLineupStore();
    expect(await store.load(), ModeLineup());

    final custom = ModeLineup().moved(4, 0).toggled(ColorMode.tiles);
    await store.save(custom);
    expect(await store.load(), custom);
  });

  group('ModeSwitcher', () {
    Future<List<int>> pumpSwitcher(WidgetTester tester) async {
      final steps = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ModeSwitcher(
                mode: modes.last,
                modes: modes,
                onStep: steps.add,
              ),
            ),
          ),
        ),
      );
      return steps;
    }

    testWidgets('tap and swipe right go next, swipe left goes back', (
      tester,
    ) async {
      final steps = await pumpSwitcher(tester);
      final pill = find.byType(ModeSwitcher);

      await tester.tap(pill);
      await tester.drag(pill, const Offset(80, 0));
      await tester.drag(pill, const Offset(-80, 0));
      await tester.pumpAndSettle();

      expect(steps, [1, 1, -1]);
    });

    testWidgets('a tiny drag is not a swipe', (tester) async {
      final steps = await pumpSwitcher(tester);
      await tester.timedDrag(
        find.byType(ModeSwitcher),
        // Past the touch slop (so not a tap), short of a swipe.
        const Offset(20, 0),
        const Duration(milliseconds: 500),
      );
      await tester.pumpAndSettle();
      expect(steps, isEmpty);
    });

    testWidgets('screen readers can adjust to next and previous', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSwitcher(tester);
      expect(
        tester.getSemantics(find.byType(ModeSwitcher)),
        matchesSemantics(
          label: 'Color mode',
          value: modes.last.label,
          hint:
              'Tap or swipe right for ${modes.first.label}, '
              'swipe left for ${modes[modes.length - 2].label}.',
          increasedValue: modes.first.label,
          decreasedValue: modes[modes.length - 2].label,
          isButton: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      handle.dispose();
    });
  });

  testWidgets('sheet switches modes off but keeps the last one on', (
    tester,
  ) async {
    var lineup = ModeLineup(
      hidden: {...ColorMode.values}
        ..remove(ColorMode.disco)
        ..remove(ColorMode.level),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSugaTheme(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModeLineupSheet(
              context,
              lineup: lineup,
              onChanged: (value) => lineup = value,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    tester.view.physicalSize = const Size(1200, 3000);
    addTearDown(tester.view.reset);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Level'));
    await tester.pumpAndSettle();
    expect(lineup.enabled, [ColorMode.disco]);
    expect(find.text('Keep at least one mode on'), findsOneWidget);

    // The last mode on can't be switched off.
    await tester.tap(find.text('Disco'));
    await tester.pumpAndSettle();
    expect(lineup.enabled, [ColorMode.disco]);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(lineup, ModeLineup());
  });
}
