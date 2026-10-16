import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:suga/audio/audio_analyzer.dart';
import 'package:suga/visuals/palette.dart';

/// Everything a visualizer needs to draw one display frame.
class Stage {
  const Stage({
    required this.time,
    required this.level,
    required this.bands,
    required this.peaks,
    required this.beats,
    required this.pulse,
    required this.spin,
  });

  factory Stage.silent(int bandCount) => Stage(
    time: 0,
    level: 0,
    bands: List.filled(bandCount, 0),
    peaks: List.filled(bandCount, 0),
    beats: 0,
    pulse: 0,
    spin: 0,
  );

  static const beatsPerPalette = 16;

  /// Seconds since the show started.
  final double time;

  /// Smoothed loudness, 0–1.
  final double level;

  /// Smoothed spectrum, bass first, each 0–1.
  final List<double> bands;

  /// Slowly falling maximum of each band (Winamp-style peak caps).
  final List<double> peaks;

  /// Beats counted so far.
  final int beats;

  /// 1 at the moment of a beat, decaying to 0 over a quarter second.
  final double pulse;

  /// Accumulated rotation in radians; turns faster when it's louder.
  final double spin;

  Palette get palette => palettes[(beats ~/ beatsPerPalette) % palettes.length];

  /// The [i]th color of the current palette, shifted by one on every beat.
  Color color(int i) {
    final colors = palette.colors;
    return colors[(i + beats) % colors.length];
  }

  /// [color] mixed toward black by [darkness] (0–1).
  Color dim(int i, double darkness) =>
      Color.lerp(color(i), const Color(0xFF000000), darkness)!;

  /// Average of the bass bands, 0–1.
  double get bass {
    final count = max(1, bands.length ~/ 6);
    return bands.take(count).fold(0.0, (a, b) => a + b) / count;
  }
}

/// Plays [AudioFrame]s out at the display rate.
///
/// Microphone audio arrives in bursts of several frames at once; feeding
/// them straight to the screen would look jerky. The director queues them
/// and releases them at their real-time pace, smoothing values between
/// frames so motion stays fluid at 60+ fps.
class StageDirector {
  StageDirector({required this.bandCount, required this.framesPerSecond})
    : _bands = List.filled(bandCount, 0),
      _targets = List.filled(bandCount, 0),
      _peaks = List.filled(bandCount, 0);

  final int bandCount;
  double framesPerSecond;

  static const _maxLatency = 0.35;
  static const _riseSeconds = 0.025;
  static const _fallSeconds = 0.16;
  static const _peakFallPerSecond = 0.5;
  static const _pulseSeconds = 0.25;

  final _queue = Queue<AudioFrame>();
  final List<double> _bands;
  final List<double> _targets;
  final List<double> _peaks;
  double _framesDue = 0;
  double _level = 0;
  double _targetLevel = 0;
  double _pulse = 0;
  double _spin = 0;
  int _beats = 0;
  Duration? _lastTick;

  void enqueue(Iterable<AudioFrame> frames) => _queue.addAll(frames);

  /// Advances to [elapsed] since the show started. With [calm] (reduced
  /// motion), beats don't pulse and rotation slows right down.
  Stage advance(Duration elapsed, {bool calm = false}) {
    final dt = _lastTick == null
        ? 0.0
        : (elapsed - _lastTick!).inMicroseconds / 1e6;
    _lastTick = elapsed;

    // Never fall further behind the microphone than _maxLatency.
    final maxQueued = (framesPerSecond * _maxLatency).ceil();
    while (_queue.length > maxQueued) {
      _consume(_queue.removeFirst());
    }

    _framesDue += dt * framesPerSecond;
    while (_framesDue >= 1 && _queue.isNotEmpty) {
      _consume(_queue.removeFirst());
      _framesDue -= 1;
    }
    if (_queue.isEmpty) _framesDue = min(_framesDue, 1);

    final rise = _approach(dt, _riseSeconds);
    final fall = _approach(dt, _fallSeconds);
    for (var i = 0; i < bandCount; i++) {
      final rate = _targets[i] > _bands[i] ? rise : fall;
      _bands[i] += (_targets[i] - _bands[i]) * rate;
      _peaks[i] = max(_bands[i], _peaks[i] - _peakFallPerSecond * dt);
    }
    _level += (_targetLevel - _level) * (_targetLevel > _level ? rise : fall);
    _pulse = max(0, _pulse - dt / _pulseSeconds);
    _spin += dt * (0.3 + 1.6 * _level) * (calm ? 0.25 : 1);

    return Stage(
      time: elapsed.inMicroseconds / 1e6,
      level: _level,
      bands: List.unmodifiable(_bands),
      peaks: List.unmodifiable(_peaks),
      beats: _beats,
      pulse: calm ? 0 : _pulse,
      spin: _spin,
    );
  }

  void _consume(AudioFrame frame) {
    for (var i = 0; i < bandCount && i < frame.bands.length; i++) {
      _targets[i] = frame.bands[i];
    }
    _targetLevel = frame.level;
    if (frame.beat) {
      _beats++;
      _pulse = 1;
    }
  }

  /// Fraction of the remaining distance to cover in [dt] for an exponential
  /// approach with time constant [seconds].
  static double _approach(double dt, double seconds) => 1 - exp(-dt / seconds);
}
