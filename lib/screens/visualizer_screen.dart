import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/audio/audio_analyzer.dart';
import 'package:suga/models/color_mode.dart';
import 'package:suga/models/mode_lineup.dart';
import 'package:suga/services/microphone_audio.dart';
import 'package:suga/services/mode_lineup_store.dart';
import 'package:suga/visuals/stage.dart';
import 'package:suga/widgets/mode_lineup_sheet.dart';
import 'package:suga/widgets/mode_switcher.dart';
import 'package:suga/widgets/visualizers/visualizer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Full-screen light show driven by the microphone.
///
/// Expects microphone access to have been granted already.
class VisualizerScreen extends StatefulWidget {
  const VisualizerScreen({super.key, this.microphone});

  /// Injectable for tests; defaults to the device microphone.
  final MicrophoneAudio? microphone;

  @override
  State<VisualizerScreen> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends State<VisualizerScreen>
    with SingleTickerProviderStateMixin {
  static const _controlsTimeout = Duration(seconds: 3);

  late final MicrophoneAudio _microphone =
      widget.microphone ?? createMicrophone();
  late final Ticker _ticker = createTicker(_onTick);
  late AudioAnalyzer _analyzer;
  late StageDirector _director;
  StreamSubscription<List<double>>? _subscription;
  Timer? _hideControls;

  final _lineupStore = ModeLineupStore();
  ModeLineup _lineup = ModeLineup();
  ColorMode _mode = ColorMode.values.first;
  int _direction = 1;
  late Stage _stage;
  bool _controlsVisible = true;
  bool _micFailed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _keepAwake(true);
    _listen();
    _showControls();
    unawaited(_loadLineup());
  }

  Future<void> _loadLineup() async {
    final lineup = await _lineupStore.load();
    if (!mounted) return;
    setState(() {
      _lineup = lineup;
      _mode = lineup.enabled.first;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _subscription?.cancel();
    _hideControls?.cancel();
    _keepAwake(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// Some browsers don't support keeping the screen awake; that's fine.
  void _keepAwake(bool enable) {
    unawaited(
      WakelockPlus.toggle(enable: enable).catchError((Object error) {
        developer.log('Wakelock unavailable', name: 'suga', error: error);
      }),
    );
  }

  void _listen() {
    _subscription?.cancel();
    _analyzer = AudioAnalyzer();
    _director = StageDirector(
      bandCount: _analyzer.bandCount,
      framesPerSecond: _analyzer.framesPerSecond,
    );
    _stage = Stage.silent(_analyzer.bandCount);

    var sampleRateChecked = false;
    _subscription = _microphone.samples.listen(
      (samples) {
        _director.enqueue(_analyzer.add(samples));
        if (!sampleRateChecked) {
          sampleRateChecked = true;
          unawaited(_matchSampleRate());
        }
      },
      onError: (Object error, StackTrace stack) {
        developer.log(
          'Microphone stream failed',
          name: 'suga',
          error: error,
          stackTrace: stack,
        );
        _subscription?.cancel();
        _ticker.stop();
        if (mounted) setState(() => _micFailed = true);
      },
    );
    if (!_ticker.isActive) unawaited(_ticker.start());
  }

  /// iOS records at the hardware rate (often 48 kHz), not the 44.1 kHz
  /// requested; analysis timing must match the real rate.
  Future<void> _matchSampleRate() async {
    try {
      final rate = await _microphone.sampleRate;
      _analyzer.sampleRate = rate;
      _director.framesPerSecond = _analyzer.framesPerSecond;
    } on Exception catch (error) {
      developer.log('Sample rate unavailable', name: 'suga', error: error);
    }
  }

  void _onTick(Duration elapsed) {
    final calm = MediaQuery.disableAnimationsOf(context);
    setState(() => _stage = _director.advance(elapsed, calm: calm));
  }

  void _retry() {
    setState(() => _micFailed = false);
    _listen();
  }

  void _showControls() {
    _hideControls?.cancel();
    setState(() => _controlsVisible = true);
    _hideControls = Timer(_controlsTimeout, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideControls?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  void _stepMode(int step) {
    setState(() {
      _direction = step;
      _mode = _lineup.step(_mode, step);
    });
    _showControls();
  }

  void _changeLineup(ModeLineup lineup) {
    setState(() {
      _lineup = lineup;
      // If the current mode was switched off, move on to the next one.
      if (!lineup.isEnabled(_mode)) _mode = lineup.step(_mode, 1);
    });
    unawaited(_lineupStore.save(lineup));
  }

  Future<void> _customizeModes() async {
    _hideControls?.cancel();
    await showModeLineupSheet(
      context,
      lineup: _lineup,
      onChanged: _changeLineup,
    );
    if (mounted) _showControls();
  }

  @override
  Widget build(BuildContext context) {
    if (_micFailed) return _MicrophoneError(onRetry: _retry);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: SugaDurations.medium,
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, ?current],
              ),
              child: KeyedSubtree(
                key: ValueKey(_mode),
                child: Visualizer(mode: _mode, stage: _stage),
              ),
            ),
            SafeArea(
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: SugaDurations.medium,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: _ControlButton(
                            tooltip: 'Close',
                            icon: Icons.close_rounded,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: _ControlButton(
                            tooltip: 'Customize modes',
                            icon: Icons.tune_rounded,
                            onPressed: _customizeModes,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ModeSwitcher(
                            mode: _mode,
                            modes: _lineup.enabled,
                            direction: _direction,
                            onStep: _stepMode,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: SugaColors.scrim,
        foregroundColor: SugaColors.ice,
        minimumSize: const Size.square(52),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _MicrophoneError extends StatelessWidget {
  const _MicrophoneError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mic_off_rounded,
                  size: 40,
                  color: SugaColors.mist,
                ),
                const SizedBox(height: 24),
                Text(
                  "Suga can't hear the microphone",
                  textAlign: TextAlign.center,
                  style: text.titleLarge?.copyWith(color: SugaColors.ice),
                ),
                const SizedBox(height: 12),
                Text(
                  'Another app may be using it. Close that app, then try again.',
                  textAlign: TextAlign.center,
                  style: text.bodyLarge?.copyWith(color: SugaColors.mist),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
