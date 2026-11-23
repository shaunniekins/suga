import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/models/music_app.dart';
import 'package:suga/screens/visualizer_screen.dart';

import 'fake_microphone.dart';

void main() {
  late FakeMicrophone microphone;
  late List<MusicApp> opened;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    microphone = FakeMicrophone();
    opened = [];
  });

  Future<void> pumpScreen(WidgetTester tester, {required bool installed}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: buildSugaTheme(),
        home: VisualizerScreen(
          microphone: microphone,
          openMusic: (app) async {
            opened.add(app);
            return installed;
          },
        ),
      ),
    );
  }

  // The visualizer animates every frame, so it never settles; pump past
  // the sheet's transition instead.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> openSpotify(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Play music'));
    await settle(tester);
    for (final app in MusicApp.values) {
      expect(find.text(app.label), findsOneWidget);
    }
    await tester.tap(find.text('Spotify'));
    await settle(tester);
  }

  testWidgets('Play music opens the chosen app', (tester) async {
    await pumpScreen(tester, installed: true);
    await openSpotify(tester);

    expect(opened, [MusicApp.spotify]);
    expect(find.text('Play music'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a missing music app is reported', (tester) async {
    await pumpScreen(tester, installed: false);
    await openSpotify(tester);

    expect(opened, [MusicApp.spotify]);
    expect(find.text("Couldn't open Spotify. Is it installed?"), findsOne);
  });

  testWidgets('the microphone stops in the background and restarts', (
    tester,
  ) async {
    await pumpScreen(tester, installed: true);
    expect(microphone.listens, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    expect(microphone.cancels, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(microphone.listens, 2);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
