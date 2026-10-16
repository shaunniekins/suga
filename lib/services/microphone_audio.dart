import 'package:suga/services/microphone_audio_device.dart'
    if (dart.library.js_interop) 'package:suga/services/microphone_audio_web.dart'
    as platform;

/// Raw microphone samples. An interface so tests can supply fake audio.
abstract interface class MicrophoneAudio {
  /// Chunks of samples between −1 and 1. Platforms deliver them in bursts
  /// (~145 ms on Android, ~0.5 s on iOS, ~46 ms on the web).
  Stream<List<double>> get samples;

  /// The rate the hardware is actually recording at; reliable only once
  /// [samples] has started.
  Future<int> get sampleRate;
}

/// The microphone for the current platform.
MicrophoneAudio createMicrophone() => platform.createMicrophone();
