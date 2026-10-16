import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/main.dart';
import 'package:suga/audio/audio_analyzer.dart';
import 'package:suga/models/color_mode.dart';
import 'package:suga/visuals/stage.dart';
import 'package:suga/widgets/visualizers/visualizer.dart';

void main() {
  testWidgets('home shows the start control and privacy note', (tester) async {
    await tester.pumpWidget(const SugaApp());
    await tester.pump(SugaDurations.reveal);

    expect(find.bySemanticsLabel('Start the light show'), findsOneWidget);
    expect(find.text('Tap the light to start'), findsOneWidget);
    expect(find.textContaining('Nothing is recorded'), findsOneWidget);
  });

  for (final mode in ColorMode.values) {
    testWidgets('${mode.label} renders through beats and silence', (
      tester,
    ) async {
      final director = StageDirector(bandCount: 24, framesPerSecond: 43);
      for (var tick = 0; tick < 40; tick++) {
        final level = (tick % 10) / 10;
        director.enqueue([
          AudioFrame(
            level: level,
            bands: List.generate(24, (b) => (level + b / 48) % 1),
            beat: tick % 8 == 0,
          ),
        ]);
        await tester.pumpWidget(
          MaterialApp(
            home: Visualizer(
              mode: mode,
              stage: director.advance(Duration(milliseconds: 25 * tick)),
            ),
          ),
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final mode in ColorMode.values) {
    testWidgets('${mode.label} fills the screen under loose constraints', (
      tester,
    ) async {
      // AnimatedSwitcher (used for the mode cross-fade) gives its children
      // loose constraints; a mode must still cover the whole screen.
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: Visualizer(mode: mode, stage: Stage.silent(24)),
          ),
        ),
      );
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(tester.getSize(find.byType(Visualizer)), screen);
    });
  }
}
