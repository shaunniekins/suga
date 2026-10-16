import 'dart:math';
import 'dart:typed_data';

/// Radix-2 FFT for real input, with a Hann window applied.
///
/// [magnitudes] is scaled so a full-scale sine centred on a bin reads ≈1.0.
class Fft {
  Fft(this.size)
    : assert(size > 1 && (size & (size - 1)) == 0, 'size must be 2^n'),
      _re = Float64List(size),
      _im = Float64List(size),
      _window = Float64List(size),
      _cos = Float64List(size ~/ 2),
      _sin = Float64List(size ~/ 2),
      _reversed = Int32List(size) {
    var windowSum = 0.0;
    for (var i = 0; i < size; i++) {
      _window[i] = 0.5 - 0.5 * cos(2 * pi * i / (size - 1));
      windowSum += _window[i];
    }
    _scale = 2 / windowSum;

    for (var k = 0; k < size ~/ 2; k++) {
      _cos[k] = cos(2 * pi * k / size);
      _sin[k] = sin(2 * pi * k / size);
    }

    final bits = (log(size) / ln2).round();
    for (var i = 0; i < size; i++) {
      var r = 0;
      for (var b = 0; b < bits; b++) {
        r = (r << 1) | ((i >> b) & 1);
      }
      _reversed[i] = r;
    }
  }

  final int size;
  final Float64List _re;
  final Float64List _im;
  final Float64List _window;
  final Float64List _cos;
  final Float64List _sin;
  final Int32List _reversed;
  late final double _scale;

  /// Magnitudes of bins `0..size/2` for `samples[offset, offset + size)`.
  Float64List magnitudes(List<double> samples, [int offset = 0]) {
    for (var i = 0; i < size; i++) {
      final j = _reversed[i];
      _re[j] = samples[offset + i] * _window[i];
      _im[j] = 0;
    }

    for (var length = 2; length <= size; length <<= 1) {
      final half = length >> 1;
      final step = size ~/ length;
      for (var start = 0; start < size; start += length) {
        for (var j = 0; j < half; j++) {
          final wr = _cos[j * step];
          final wi = -_sin[j * step];
          final a = start + j;
          final b = a + half;
          final tr = _re[b] * wr - _im[b] * wi;
          final ti = _re[b] * wi + _im[b] * wr;
          _re[b] = _re[a] - tr;
          _im[b] = _im[a] - ti;
          _re[a] += tr;
          _im[a] += ti;
        }
      }
    }

    final out = Float64List(size ~/ 2 + 1);
    for (var k = 0; k < out.length; k++) {
      out[k] = sqrt(_re[k] * _re[k] + _im[k] * _im[k]) * _scale;
    }
    return out;
  }
}
