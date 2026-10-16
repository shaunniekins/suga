import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:suga/audio/audio_analyzer.dart';
import 'package:suga/audio/fft.dart';

const rate = 44100;

/// [seconds] of audio: quiet hiss plus a 60 Hz kick drum every [beatEvery]
/// seconds, optionally over a steady [toneHz] tone.
List<double> track(
  double seconds, {
  double? beatEvery,
  double? toneHz,
  double tone = 0.2,
}) {
  final random = Random(1);
  return List.generate((seconds * rate).round(), (i) {
    final t = i / rate;
    var sample = (random.nextDouble() - 0.5) * 0.002;
    if (toneHz != null) sample += tone * sin(2 * pi * toneHz * t);
    if (beatEvery != null) {
      final sinceKick = t % beatEvery;
      sample += 0.7 * exp(-sinceKick * 30) * sin(2 * pi * 60 * sinceKick);
    }
    return sample;
  });
}

List<AudioFrame> analyze(List<double> samples) {
  final analyzer = AudioAnalyzer(sampleRate: rate);
  // Feed in Android-sized bursts to exercise buffering.
  final frames = <AudioFrame>[];
  for (var i = 0; i < samples.length; i += 6400) {
    frames.addAll(
      analyzer.add(samples.sublist(i, min(i + 6400, samples.length))),
    );
  }
  return frames;
}

void main() {
  test('FFT finds a sine at its bin with ~unit magnitude', () {
    final fft = Fft(1024);
    final samples = List.generate(1024, (i) => sin(2 * pi * 32 * i / 1024));
    final magnitudes = fft.magnitudes(samples);
    final loudest = magnitudes.indexOf(magnitudes.reduce(max));
    expect(loudest, 32);
    expect(magnitudes[32], closeTo(1, 0.05));
  });

  test('silence stays dark and beat-free', () {
    final frames = analyze(track(3));
    expect(frames.where((f) => f.beat), isEmpty);
    expect(frames.map((f) => f.level).reduce(max), lessThan(0.05));
    expect(frames.last.bands.reduce(max), lessThan(0.05));
  });

  test('detects a 120 BPM kick drum on the beat', () {
    final frames = analyze(track(6, beatEvery: 0.5));
    final beats = frames.where((f) => f.beat).length;
    expect(beats, inInclusiveRange(10, 13));
  });

  test('detects kicks over loud steady music', () {
    final frames = analyze(track(6, beatEvery: 0.5, toneHz: 440, tone: 0.3));
    expect(frames.where((f) => f.beat).length, inInclusiveRange(10, 13));
    // Automatic gain keeps loudness moving instead of pinned at full.
    final levels = frames.skip(frames.length ~/ 2).map((f) => f.level);
    expect(levels.reduce(max) - levels.reduce(min), greaterThan(0.2));
  });

  test('never reports more than 3 beats a second', () {
    final frames = analyze(track(4, beatEvery: 0.1));
    final perSecond = AudioAnalyzer(sampleRate: rate).framesPerSecond;
    final beats = frames.where((f) => f.beat).length;
    expect(beats / (frames.length / perSecond), lessThanOrEqualTo(3));
  });

  test('bass and treble land at opposite ends of the spectrum', () {
    int loudestBand(double hz) {
      final bands = analyze(track(1, toneHz: hz, tone: 0.5)).last.bands;
      return bands.indexOf(bands.reduce(max));
    }

    expect(loudestBand(80), lessThan(6));
    expect(loudestBand(8000), greaterThan(16));
  });
}
