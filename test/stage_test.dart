import 'package:flutter_test/flutter_test.dart';
import 'package:suga/audio/audio_analyzer.dart';
import 'package:suga/visuals/palette.dart';
import 'package:suga/visuals/stage.dart';

AudioFrame frame({double level = 0.5, bool beat = false}) =>
    AudioFrame(level: level, bands: List.filled(4, level), beat: beat);

Duration ms(int value) => Duration(milliseconds: value);

void main() {
  test('releases a burst of frames gradually, not all at once', () {
    final director = StageDirector(bandCount: 4, framesPerSecond: 40);
    director.advance(Duration.zero);
    director.enqueue([
      for (var i = 0; i < 6; i++) frame(beat: i == 0 || i == 5),
    ]);

    // One 60 fps tick releases at most one 40 fps frame.
    expect(director.advance(ms(16)).beats, 0);
    expect(director.advance(ms(33)).beats, 1);
    // The last beat comes out ~125 ms after the first, as in the audio.
    expect(director.advance(ms(140)).beats, 1);
    expect(director.advance(ms(200)).beats, 2);
  });

  test('beats pulse, then the pulse fades', () {
    final director = StageDirector(bandCount: 4, framesPerSecond: 40);
    director.advance(Duration.zero);
    director.enqueue([frame(beat: true)]);
    expect(director.advance(ms(30)).pulse, greaterThan(0.8));
    expect(director.advance(ms(400)).pulse, 0);
  });

  test('calm mode suppresses the beat pulse', () {
    final director = StageDirector(bandCount: 4, framesPerSecond: 40);
    director.advance(Duration.zero, calm: true);
    director.enqueue([frame(beat: true)]);
    final stage = director.advance(ms(30), calm: true);
    expect(stage.beats, 1);
    expect(stage.pulse, 0);
  });

  test('caps latency when frames pile up', () {
    final director = StageDirector(bandCount: 4, framesPerSecond: 40);
    director.advance(Duration.zero);
    director.enqueue([for (var i = 0; i < 100; i++) frame(beat: true)]);
    // Everything older than ~0.35 s is applied at once.
    expect(director.advance(ms(16)).beats, greaterThan(80));
  });

  test('colors rotate every beat and palettes change every 16', () {
    Stage at(int beats) => Stage(
      time: 0,
      level: 0,
      bands: const [0],
      peaks: const [0],
      beats: beats,
      pulse: 0,
      spin: 0,
    );

    expect(at(1).color(0), at(0).color(1));
    expect(at(0).palette, palettes[0]);
    expect(at(Stage.beatsPerPalette).palette, palettes[1]);
  });

  test('colorAt hits the end stops exactly', () {
    expect(colorAt(meterSpectrum, 0), meterSpectrum.first);
    expect(colorAt(meterSpectrum, 1), meterSpectrum.last);
  });
}
