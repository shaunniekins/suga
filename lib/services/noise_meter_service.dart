import 'dart:async';
import 'package:noise_meter/noise_meter.dart';

typedef DataCallback = void Function(NoiseReading);
typedef ErrorCallback = void Function(Object);

class NoiseMeterService {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;

  DataCallback? onData;
  ErrorCallback? onError;

  Future<void> start() async {
    _noiseMeter ??= NoiseMeter();
    _noiseSubscription = _noiseMeter?.noise.listen(onData, onError: onError);
  }

  void stop() {
    _noiseSubscription?.cancel();
  }

  void dispose() {
    stop();
  }
}
