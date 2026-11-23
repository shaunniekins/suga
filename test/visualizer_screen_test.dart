import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/models/color_mode.dart';
import 'package:suga/screens/visualizer_screen.dart';

import 'fake_microphone.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSugaTheme(),
        home: VisualizerScreen(
          microphone: FakeMicrophone(),
          openMusic: (_) async => true,
        ),
      ),
    );
    await tester.pump();
  }

  String? currentMode(WidgetTester tester) => tester
      .getSemantics(find.bySemanticsLabel('Color mode'))
      .getSemanticsData()
      .value;

  testWidgets('swiping anywhere on the show changes mode', (tester) async {
    await pumpScreen(tester);
    final modes = ColorMode.values;
    expect(currentMode(tester), modes.first.label);

    await tester.fling(
      find.byType(VisualizerScreen),
      const Offset(300, 0),
      1000,
    );
    await tester.pump(SugaDurations.medium);
    expect(currentMode(tester), modes[1].label);

    await tester.fling(
      find.byType(VisualizerScreen),
      const Offset(-300, 0),
      1000,
    );
    await tester.pump(SugaDurations.medium);
    expect(currentMode(tester), modes.first.label);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('arrow keys change mode', (tester) async {
    await pumpScreen(tester);
    final modes = ColorMode.values;

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump(SugaDurations.medium);
    expect(currentMode(tester), modes[1].label);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump(SugaDurations.medium);
    expect(currentMode(tester), modes.last.label);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
