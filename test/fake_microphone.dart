import 'dart:async';

import 'package:suga/services/microphone_audio.dart';

/// A microphone that never sends sound but counts listens and cancels.
class FakeMicrophone implements MicrophoneAudio {
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
