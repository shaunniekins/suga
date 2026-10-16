import 'dart:math';

import 'package:suga/audio/fft.dart';

/// One analysis window of microphone audio (~23 ms at 44.1 kHz).
class AudioFrame {
  const AudioFrame({
    required this.level,
    required this.bands,
    required this.beat,
  });

  /// Overall loudness, 0–1, relative to the recent loudest moment.
  final double level;

  /// Spectrum from bass (index 0) to treble, each 0–1.
  final List<double> bands;

  /// Whether a beat (kick, clap, sharp hit) starts in this window.
  final bool beat;
}

/// Turns raw microphone samples into [AudioFrame]s: loudness, a log-spaced
/// spectrum and beat onsets.
///
/// Levels use automatic gain: they're measured against a slowly falling
/// recent peak, so quiet background music and a loud party both use the
/// full 0–1 range. Floors keep a silent room dark.
class AudioAnalyzer {
  AudioAnalyzer({
    int sampleRate = 44100,
    this.bandCount = 24,
    this.fftSize = 1024,
  }) : _fft = Fft(fftSize),
       _sampleRate = sampleRate {
    _mapBands();
  }

  final int bandCount;
  final int fftSize;
  final Fft _fft;
  int _sampleRate;

  /// Hits closer together than this don't count as new beats. It also caps
  /// beat-driven full-screen flashes below 3 per second (WCAG 2.3.1).
  static const minBeatGap = Duration(milliseconds: 340);

  static const _lowestHz = 40.0;
  static const _highestHz = 16000.0;
  static const _bassTopHz = 160.0;
  static const _dynamicRangeDb = 40.0;
  static const _levelRangeDb = 24.0;
  static const _peakFloorDb = -36.0;
  static const _levelFloorDb = -30.0;
  static const _peakFallDbPerSecond = 4.0;
  static const _historySeconds = 1.0;

  late List<(int, int)> _bandBins;
  late int _bassTopBin;

  final List<double> _pending = [];
  final List<double> _bassHistory = [];
  final List<double> _energyHistory = [];
  double _bandPeakDb = _peakFloorDb;
  double _levelPeakDb = _levelFloorDb;
  int _framesSinceBeat = 1 << 20;

  int get sampleRate => _sampleRate;

  set sampleRate(int value) {
    if (value == _sampleRate || value <= 0) return;
    _sampleRate = value;
    _mapBands();
  }

  /// Analysis frames per second of audio.
  double get framesPerSecond => _sampleRate / fftSize;

  /// Splits [bandCount] bands evenly on a log scale between [_lowestHz] and
  /// [_highestHz], giving every band at least one FFT bin.
  void _mapBands() {
    final binHz = _sampleRate / fftSize;
    final maxBin = fftSize ~/ 2;
    int binFor(double hz) => (hz / binHz).round().clamp(1, maxBin);

    _bandBins = [];
    var previousEnd = binFor(_lowestHz);
    for (var i = 0; i < bandCount; i++) {
      final hz = _lowestHz * pow(_highestHz / _lowestHz, (i + 1) / bandCount);
      final start = previousEnd;
      final end = max(start + 1, binFor(hz.toDouble()));
      _bandBins.add((start, min(end, maxBin + 1)));
      previousEnd = end;
    }
    _bassTopBin = max(2, binFor(_bassTopHz));
  }

  /// Feeds samples (−1 to 1) and returns any frames completed by them.
  List<AudioFrame> add(List<double> samples) {
    _pending.addAll(samples);
    final frames = <AudioFrame>[];
    var offset = 0;
    while (_pending.length - offset >= fftSize) {
      frames.add(_analyze(offset));
      offset += fftSize;
    }
    _pending.removeRange(0, offset);
    return frames;
  }

  AudioFrame _analyze(int offset) {
    final secondsPerFrame = 1 / framesPerSecond;

    var sumSquares = 0.0;
    for (var i = offset; i < offset + fftSize; i++) {
      sumSquares += _pending[i] * _pending[i];
    }
    final rms = sqrt(sumSquares / fftSize);
    final magnitudes = _fft.magnitudes(_pending, offset);

    // Loudness with automatic gain.
    final levelDb = _decibels(rms);
    _levelPeakDb = max(
      max(levelDb, _levelFloorDb),
      _levelPeakDb - _peakFallDbPerSecond * secondsPerFrame,
    );
    final level = _scale(levelDb, _levelPeakDb, _levelRangeDb);

    // Spectrum. Higher bands get a gentle boost (~3 dB/octave) because
    // music carries far less energy up there; without it, treble bars
    // barely move.
    final bandDb = List<double>.filled(bandCount, 0);
    var loudestBand = double.negativeInfinity;
    for (var b = 0; b < bandCount; b++) {
      final (start, end) = _bandBins[b];
      var power = 0.0;
      for (var k = start; k < end; k++) {
        power += magnitudes[k] * magnitudes[k];
      }
      final tilt = 9 * b / max(1, bandCount - 1);
      bandDb[b] = _decibels(sqrt(power / (end - start))) + tilt;
      loudestBand = max(loudestBand, bandDb[b]);
    }
    _bandPeakDb = max(
      max(loudestBand, _peakFloorDb),
      _bandPeakDb - _peakFallDbPerSecond * secondsPerFrame,
    );
    final bands = [
      for (final db in bandDb) _scale(db, _bandPeakDb, _dynamicRangeDb),
    ];

    // Beats: energy noticeably above the last second's average, in the bass
    // (kicks) or across the whole signal (claps, snares).
    var bass = 0.0;
    for (var k = 1; k <= _bassTopBin; k++) {
      bass += magnitudes[k] * magnitudes[k];
    }
    final energy = rms * rms;
    final historyLength = max(8, (_historySeconds * framesPerSecond).round());
    final bassAverage = _average(_bassHistory);
    final energyAverage = _average(_energyHistory);
    _push(_bassHistory, bass, historyLength);
    _push(_energyHistory, energy, historyLength);

    final bassHit = bass > 1e-5 && bass > bassAverage * 1.6;
    final energyHit = energy > 1e-5 && energy > energyAverage * 1.8;
    final gapFrames = (minBeatGap.inMicroseconds / 1e6 * framesPerSecond)
        .ceil();

    _framesSinceBeat++;
    final beat = (bassHit || energyHit) && _framesSinceBeat >= gapFrames;
    if (beat) _framesSinceBeat = 0;

    return AudioFrame(level: level, bands: bands, beat: beat);
  }

  static double _decibels(double amplitude) =>
      amplitude <= 1e-9 ? -180 : 20 * log(amplitude) / ln10;

  static double _scale(double db, double peakDb, double rangeDb) =>
      ((db - (peakDb - rangeDb)) / rangeDb).clamp(0.0, 1.0);

  static double _average(List<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

  static void _push(List<double> history, double value, int length) {
    history.add(value);
    if (history.length > length) history.removeAt(0);
  }
}
