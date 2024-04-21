//noise_meter.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:suga/models/color_mode.dart';
import 'package:suga/services/noise_meter_service.dart';
import 'package:suga/utils/permissions.dart';

class NoiseMeterWidget extends StatefulWidget {
  const NoiseMeterWidget({super.key});

  @override
  _NoiseMeterWidgetState createState() => _NoiseMeterWidgetState();
}

class _NoiseMeterWidgetState extends State<NoiseMeterWidget> {
  final NoiseMeterService _noiseMeterService = NoiseMeterService();

  Color _backgroundColor = Colors.white;
  ColorMode _colorMode = ColorMode.assorted;
  List<Color> _tileColors = [];
  double _levelHeight = 0.0;

  bool _isStopped = false;

  @override
  void initState() {
    super.initState();
    _noiseMeterService.onData = onData;
    _noiseMeterService.onError = onError;
    _noiseMeterService.start();
    _checkAndStartNoiseMeter();
  }

  @override
  void dispose() {
    _noiseMeterService.onData = null;
    _noiseMeterService.stop();
    super.dispose();
  }
  // void onData(NoiseReading noiseReading) {
  //   setState(() {
  //     _changeBackgroundColor(noiseReading.meanDecibel);
  //   });
  // }

  Future<void> _checkAndStartNoiseMeter() async {
    if (await checkPermission()) {
      _noiseMeterService.start();
    } else {
      await requestPermission();
    }
  }

  double _previousNoiseLevel = 0.0;
  final double _minDecibel = 20.0;

  void onData(NoiseReading noiseReading) {
    if (_isStopped) {
      return;
    }

    if (noiseReading.meanDecibel != _previousNoiseLevel &&
        noiseReading.meanDecibel > _minDecibel) {
      _previousNoiseLevel = noiseReading.meanDecibel;
      if (mounted) {
        setState(() {
          _changeBackgroundColor(noiseReading.meanDecibel);
          _updateLevelHeight(noiseReading.meanDecibel);
        });
      }
    }
  }

  void onError(Object error) {
    print(error);
    stop();
  }

  void stop() {
    _isStopped = true;
    _noiseMeterService.onData = null;
    _noiseMeterService.stop();
  }

  void _changeBackgroundColor(double noiseLevel) {
    final random = Random();
    switch (_colorMode) {
      case ColorMode.assorted:
        _backgroundColor = Color.fromARGB(
          255,
          random.nextInt(256 - noiseLevel.toInt()),
          random.nextInt(256 - noiseLevel.toInt()),
          random.nextInt(256 - noiseLevel.toInt()),
        );
        break;
      case ColorMode.blackAndWhite:
        _backgroundColor =
            _backgroundColor == Colors.white ? Colors.black : Colors.white;
        break;
      case ColorMode.gradient:
        final intensity = noiseLevel / 100;
        _backgroundColor = Color.lerp(Colors.blue, Colors.red, intensity)!;
        break;
      case ColorMode.tiles:
        _updateTileColors(noiseLevel);
        break;
      case ColorMode.level:
        _updateLevelHeight(noiseLevel);
        break;
    }
  }

  void _updateTileColors(double noiseLevel) {
    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const tileSize = 50.0;

    final crossAxisCount = (screenWidth / tileSize).floor();
    final rowCount = (screenHeight / tileSize).floor();
    final totalTiles = crossAxisCount * rowCount;

    _tileColors = List.generate(
      totalTiles,
      (index) => Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ),
    );
  }

  void _updateLevelHeight(double noiseLevel) {
    _levelHeight = noiseLevel / 100;
  }

  void _changeColorMode() {
    setState(() {
      _colorMode =
          ColorMode.values[(_colorMode.index + 1) % ColorMode.values.length];
      _tileColors.clear();
      _levelHeight = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return PopScope(
        canPop: true,
        onPopInvoked: (didPop) async {
          stop();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (_colorMode == ColorMode.tiles)
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                  ),
                  itemCount: _tileColors.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: _tileColors[index],
                    );
                  },
                ),
              if (_colorMode == ColorMode.level)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * _levelHeight,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (_colorMode != ColorMode.tiles &&
                  _colorMode != ColorMode.level)
                Container(
                  color: _backgroundColor,
                ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.blue,
                      onPressed: _changeColorMode,
                      child: const Icon(Icons.color_lens),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
