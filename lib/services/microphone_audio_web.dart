import 'dart:async';
import 'dart:js_interop';

import 'package:suga/services/microphone_audio.dart';
import 'package:web/web.dart' as web;

MicrophoneAudio createMicrophone() => _WebMicrophone();

/// Browsers, through `getUserMedia` and the Web Audio API.
///
/// Uses a `ScriptProcessorNode` because, unlike an `AudioWorklet`, it needs no
/// separate JavaScript module and works in every current browser.
class _WebMicrophone implements MicrophoneAudio {
  static const _bufferSize = 2048;

  web.AudioContext? _context;

  @override
  Future<int> get sampleRate async => (_context?.sampleRate ?? 44100).round();

  @override
  Stream<List<double>> get samples {
    web.MediaStream? media;
    web.MediaStreamAudioSourceNode? source;
    web.ScriptProcessorNode? processor;
    late final StreamController<List<double>> controller;

    Future<void> start() async {
      try {
        media = await web.window.navigator.mediaDevices
            .getUserMedia(web.MediaStreamConstraints(audio: true.toJS))
            .toDart;
        final context = _context = web.AudioContext();
        // Browsers start audio suspended until a user gesture; the tap that
        // opened the visualizer counts.
        await context.resume().toDart;

        source = context.createMediaStreamSource(media!);
        processor = context.createScriptProcessor(_bufferSize, 1, 1)
          ..onaudioprocess = (web.AudioProcessingEvent event) {
            final channel = event.inputBuffer.getChannelData(0).toDart;
            controller.add(List<double>.of(channel));
          }.toJS;
        // The processor only runs while connected to an output. Its output
        // buffer is left silent, so nothing is played back.
        source!.connect(processor!);
        processor!.connect(context.destination);
      } catch (error, stack) {
        controller.addError(error, stack);
      }
    }

    Future<void> stop() async {
      processor?.onaudioprocess = null;
      processor?.disconnect();
      source?.disconnect();
      for (final track
          in media?.getTracks().toDart ?? <web.MediaStreamTrack>[]) {
        track.stop();
      }
      await _context?.close().toDart;
      _context = null;
    }

    controller = StreamController<List<double>>(
      onListen: () => unawaited(start()),
      onCancel: stop,
    );
    return controller.stream;
  }
}
