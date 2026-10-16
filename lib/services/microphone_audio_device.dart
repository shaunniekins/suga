import 'package:audio_streamer/audio_streamer.dart';
import 'package:suga/services/microphone_audio.dart';

MicrophoneAudio createMicrophone() => _DeviceMicrophone();

/// Android and iOS, through the `audio_streamer` plugin.
class _DeviceMicrophone implements MicrophoneAudio {
  @override
  Stream<List<double>> get samples => AudioStreamer().audioStream;

  @override
  Future<int> get sampleRate => AudioStreamer().actualSampleRate;
}
