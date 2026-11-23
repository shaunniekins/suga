import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/models/music_app.dart';
import 'package:suga/screens/visualizer_screen.dart';
import 'package:suga/services/microphone_audio.dart';

class _FakeMicrophone implements MicrophoneAudio {
  int listens = 0;
  int cancels = 0;

  @override
  Stream<List<double>> get samples {
    late final StreamController<List<double>> controller;
    controller = StreamController<List<double>>(
      onListen: () => listens++,
      onCancel: () => cancels++,
    );
    return controller.stream;
  }

  @override
  Future<int> get sampleRate async => 44100;
}

void main() {
  late _FakeMicrophone microphone;
  late List<MusicApp> opened;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    microphone = _FakeMicrophone();
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
