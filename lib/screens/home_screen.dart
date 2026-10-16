import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/screens/visualizer_screen.dart';
import 'package:suga/services/microphone_permission.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _lampSize = 168.0;

  final _lampKey = GlobalKey();
  bool _starting = false;

  Future<void> _start() async {
    if (_starting) return;
    setState(() => _starting = true);
    final access = await requestMicrophoneAccess();
    if (!mounted) return;
    setState(() => _starting = false);

    switch (access) {
      case MicrophoneAccess.granted:
        await Navigator.of(context).push(_revealRoute());
      case MicrophoneAccess.denied:
        _explain(
          'Suga needs the microphone to hear the room.',
          action: SnackBarAction(label: 'Allow', onPressed: _start),
        );
      case MicrophoneAccess.blocked when canOpenMicrophoneSettings:
        _explain(
          'Microphone access is turned off for Suga.',
          action: SnackBarAction(
            label: 'Open settings',
            onPressed: openMicrophoneSettings,
          ),
        );
      case MicrophoneAccess.blocked:
        _explain(
          'The microphone is blocked for this site. Allow it from the '
          'address bar, then try again.',
          action: SnackBarAction(label: 'Try again', onPressed: _start),
        );
      case MicrophoneAccess.unavailable:
        _explain(
          "Suga can't find a microphone. Connect one, or open Suga over "
          'HTTPS.',
        );
    }
  }

  void _explain(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  /// The visualizer grows out of the lamp as a circle, as if it switched on.
  Route<void> _revealRoute() {
    final box = _lampKey.currentContext?.findRenderObject() as RenderBox?;
    final center = box?.localToGlobal(box.size.center(Offset.zero));
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return PageRouteBuilder<void>(
      transitionDuration: SugaDurations.reveal,
      reverseTransitionDuration: SugaDurations.medium,
      pageBuilder: (_, _, _) => const VisualizerScreen(),
      transitionsBuilder: (context, animation, _, child) {
        if (reduceMotion || center == null) {
          return FadeTransition(opacity: animation, child: child);
        }
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, child) => ClipPath(
            clipper: _CircleRevealClipper(
              center: center,
              startRadius: _lampSize / 2,
              progress: curved.value,
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.9,
            colors: [SugaColors.slate, SugaColors.night],
          ),
        ),
        child: SafeArea(
          child: SizedBox.expand(
            child: Column(
              children: [
                const Spacer(flex: 3),
                _Lamp(
                  key: _lampKey,
                  size: _lampSize,
                  busy: _starting,
                  onPressed: _start,
                ),
                const SizedBox(height: 40),
                const _Wordmark(),
                const SizedBox(height: 10),
                const Text(
                  'Sound becomes light.',
                  style: TextStyle(color: SugaColors.mist, fontSize: 17),
                ),
                const Spacer(flex: 4),
                const Text(
                  'Tap the light to start',
                  style: TextStyle(
                    color: SugaColors.ice,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Uses the microphone. Nothing is recorded.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SugaColors.mist, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  static const _tracking = 14.0;

  @override
  Widget build(BuildContext context) {
    // Letter spacing trails the last glyph too; the left pad re-centres it.
    return const Padding(
      padding: EdgeInsets.only(left: _tracking),
      child: Text(
        'suga',
        semanticsLabel: 'Suga',
        style: TextStyle(
          color: SugaColors.ice,
          fontSize: 44,
          fontWeight: FontWeight.w200,
          letterSpacing: _tracking,
          height: 1,
        ),
      ),
    );
  }
}

/// The logo as a lamp: it breathes a soft blue glow until tapped.
class _Lamp extends StatefulWidget {
  const _Lamp({
    super.key,
    required this.size,
    required this.busy,
    required this.onPressed,
  });

  final double size;
  final bool busy;
  final VoidCallback onPressed;

  @override
  State<_Lamp> createState() => _LampState();
}

class _LampState extends State<_Lamp> with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: SugaDurations.breathe,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _breath
        ..stop()
        ..value = 0.5;
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = CurvedAnimation(parent: _breath, curve: Curves.easeInOut);

    return Semantics(
      button: true,
      label: 'Start the light show',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: SugaDurations.reveal,
        curve: Curves.easeOutCubic,
        builder: (context, entrance, child) => Opacity(
          opacity: entrance,
          child: Transform.scale(scale: 0.9 + 0.1 * entrance, child: child),
        ),
        child: AnimatedBuilder(
          animation: glow,
          builder: (context, child) => DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SugaColors.signal.withValues(
                    alpha: 0.22 + 0.2 * glow.value,
                  ),
                  blurRadius: 36 + 32 * glow.value,
                  spreadRadius: 2 + 8 * glow.value,
                ),
              ],
            ),
            child: child,
          ),
          child: Material(
            shape: const CircleBorder(
              side: BorderSide(color: Color(0x334DA3F0), width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            color: SugaColors.slate,
            child: Ink.image(
              image: const AssetImage('assets/icons/app_icon_source.png'),
              fit: BoxFit.cover,
              width: widget.size,
              height: widget.size,
              child: InkWell(
                onTap: widget.busy ? null : widget.onPressed,
                splashColor: SugaColors.signal.withValues(alpha: 0.3),
                child: AnimatedOpacity(
                  opacity: widget.busy ? 1 : 0,
                  duration: SugaDurations.quick,
                  child: const Center(
                    child: SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: SugaColors.ice,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  _CircleRevealClipper({
    required this.center,
    required this.startRadius,
    required this.progress,
  });

  final Offset center;
  final double startRadius;
  final double progress;

  @override
  Path getClip(Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    final farthest = corners
        .map((corner) => (corner - center).distance)
        .reduce(max);
    final radius = startRadius + (farthest - startRadius) * progress;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) =>
      oldClipper.progress != progress || oldClipper.center != center;
}
