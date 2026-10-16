// Renders the store screenshots, Play feature graphic and website images from
// the real app widgets, driven by synthetic music. Run via
// tool/store/generate.sh (it also makes the WebP and icon files).
//
// Lives outside test/ so `flutter test` doesn't regenerate images every run.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/audio/audio_analyzer.dart';
import 'package:suga/models/color_mode.dart';
import 'package:suga/models/mode_lineup.dart';
import 'package:suga/screens/home_screen.dart';
import 'package:suga/visuals/stage.dart';
import 'package:suga/widgets/mode_lineup_sheet.dart';
import 'package:suga/widgets/mode_switcher.dart';
import 'package:suga/widgets/visualizers/visualizer.dart';

const _iconPath = 'assets/icons/app_icon_source.png';

/// The app's screen size on a phone (iPhone 15/16 class).
const _phone = Size(393, 852);

/// The app's screen size on a 13" iPad in portrait.
const _tablet = Size(1032, 1376);

const _navy = Color(0xFF00235C);

class _Shot {
  const _Shot(this.name, this.title, this.subtitle, this.screen);

  final String name;
  final String title;
  final String subtitle;
  final _Screen screen;
}

enum _Screen { disco, spectrum, pulse, customize, home }

const _shots = [
  _Shot(
    '01-light-up-the-room',
    'Play music.\nThe room lights up.',
    'Suga hears the beat and lights it up.',
    _Screen.disco,
  ),
  _Shot(
    '02-spectrum',
    'Winamp-style bars,\nlive from the mic.',
    '24 bands, bass to treble, with falling peaks.',
    _Screen.spectrum,
  ),
  _Shot(
    '03-every-beat',
    'A ring of color\non every beat.',
    'The colors shift with every beat.',
    _Screen.pulse,
  ),
  _Shot(
    '04-your-modes',
    'Your modes,\nin your order.',
    'Switch modes off and drag to reorder.',
    _Screen.customize,
  ),
  _Shot(
    '05-never-records',
    'It listens.\nIt never records.',
    'Nothing is saved or sent. No account.',
    _Screen.home,
  ),
];

void main() {
  setUpAll(_loadFonts);

  group('Google Play', () {
    for (final shot in _shots) {
      testWidgets('phone ${shot.name}', (t) async {
        await _renderShot(
          t,
          shot,
          canvas: const Size(1080, 1920),
          device: _phone,
          out: 'store/google-play/phone-screenshots/${shot.name}.png',
        );
      });
    }

    testWidgets('icon', (t) async {
      // Rendered rather than resized so it's a 32-bit PNG, as Play asks.
      const size = Size(512, 512);
      await _show(
        t,
        canvas: size,
        ratio: 1,
        child: Image.asset(_iconPath, width: 512, height: 512),
      );
      await t.pump();
      await _capture(t, 1, 'store/google-play/icon-512.png');
    });

    testWidgets('feature graphic', (t) async {
      await _renderBanner(
        t,
        canvas: const Size(1024, 500),
        out: 'store/google-play/feature-graphic.png',
      );
    });
  });

  group('App Store', () {
    for (final shot in _shots) {
      testWidgets('iPhone 6.9" ${shot.name}', (t) async {
        await _renderShot(
          t,
          shot,
          canvas: const Size(1320, 2868),
          device: _phone,
          out: 'store/app-store/iphone-6.9/${shot.name}.png',
        );
      });
      testWidgets('iPad 13" ${shot.name}', (t) async {
        await _renderShot(
          t,
          shot,
          canvas: const Size(2064, 2752),
          device: _tablet,
          out: 'store/app-store/ipad-13/${shot.name}.png',
        );
      });
    }
  });

  group('Website', () {
    testWidgets('social card', (t) async {
      await _renderBanner(
        t,
        canvas: const Size(1200, 630),
        out: 'build/store/og.png',
      );
    });

    testWidgets('hero screen', (t) async {
      await _renderScreen(
        t,
        _Screen.disco,
        device: _phone,
        pixelRatio: 2,
        out: 'build/store/screens/hero.png',
      );
    });

    for (final mode in ColorMode.values) {
      testWidgets('mode ${mode.name}', (t) async {
        await _renderMode(t, mode, out: 'build/store/screens/${mode.name}.png');
      });
    }
  });
}

// ---------------------------------------------------------------------------
// Compositions

Future<void> _renderShot(
  WidgetTester t,
  _Shot shot, {
  required Size canvas,
  required Size device,
  required String out,
}) async {
  // Lay out at a phone-like logical width so type scales with the canvas.
  final logicalWidth = canvas.width > 1800 ? 1032.0 : 430.0;
  final ratio = canvas.width / logicalWidth;
  final logical = canvas / ratio;
  final tablet = device == _tablet;

  final innerKey = GlobalKey();
  await _show(
    t,
    canvas: canvas,
    ratio: ratio,
    child: _Backdrop(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          logical.width * 0.07,
          logical.height * (tablet ? 0.05 : 0.065),
          logical.width * 0.07,
          0,
        ),
        child: Column(
          children: [
            Text(
              shot.title,
              textAlign: TextAlign.center,
              style: _sora(
                size: logical.width * (tablet ? 0.06 : 0.082),
                weight: 600,
                height: 1.12,
              ),
            ),
            SizedBox(height: logical.height * 0.016),
            Text(
              shot.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: logical.width * (tablet ? 0.024 : 0.037),
                color: SugaColors.mist,
                height: 1.35,
              ),
            ),
            SizedBox(height: logical.height * 0.04),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: _DeviceFrame(
                  device: device,
                  child: _AppScreen(key: innerKey, device: device),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  await _play(t, innerKey, shot.screen);
  await _capture(t, ratio, out);
}

Future<void> _renderScreen(
  WidgetTester t,
  _Screen screen, {
  required Size device,
  required double pixelRatio,
  required String out,
}) async {
  final innerKey = GlobalKey();
  await _show(
    t,
    canvas: device * pixelRatio,
    ratio: pixelRatio,
    child: _AppScreen(key: innerKey, device: device),
  );
  await _play(t, innerKey, screen);
  await _capture(t, pixelRatio, out);
}

/// A single mode with no controls, for the website's mode grid.
Future<void> _renderMode(
  WidgetTester t,
  ColorMode mode, {
  required String out,
}) {
  const ratio = 1.5;
  return _drive(
    t,
    canvas: _phone * ratio,
    ratio: ratio,
    seconds: 4.3,
    // A single frame of Black & white is just a white (or black) page, which
    // reads as a broken image; show both states it flips between instead.
    build: (stage) => mode == ColorMode.blackAndWhite
        ? const Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: Colors.black),
              ClipPath(
                clipper: _DiagonalClipper(),
                child: ColoredBox(color: Colors.white),
              ),
            ],
          )
        : Visualizer(mode: mode, stage: stage),
  ).then((_) => _capture(t, ratio, out));
}

class _DiagonalClipper extends CustomClipper<Path> {
  const _DiagonalClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height * 0.35)
    ..lineTo(0, size.height * 0.65)
    ..close();

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}

/// Icon, wordmark and tagline beside the Disco visual.
Future<void> _renderBanner(
  WidgetTester t, {
  required Size canvas,
  required String out,
}) async {
  const ratio = 1.0;
  final h = canvas.height;
  await _drive(
    t,
    canvas: canvas,
    ratio: ratio,
    seconds: 4.3,
    build: (stage) => Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: canvas.width * 0.2,
          top: 0,
          right: -canvas.width * 0.12,
          bottom: 0,
          child: Visualizer(mode: ColorMode.disco, stage: stage),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              stops: [0.34, 0.62],
              colors: [SugaColors.night, Color(0x000E161D)],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: canvas.width * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(h * 0.06),
                child: Image.asset(
                  _iconPath,
                  width: h * 0.24,
                  height: h * 0.24,
                ),
              ),
              SizedBox(height: h * 0.06),
              Text(
                'suga',
                style: _sora(
                  size: h * 0.2,
                  weight: 250,
                  spacing: h * 0.03,
                  height: 1,
                ),
              ),
              SizedBox(height: h * 0.035),
              Text(
                'Sound becomes light.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: h * 0.06,
                  color: SugaColors.mist,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  await _capture(t, ratio, out);
}

// ---------------------------------------------------------------------------
// Pieces

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SugaColors.night, Color(0xFF0B1B3A), _navy],
          stops: [0, 0.55, 1],
        ),
      ),
      child: child,
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.device, required this.child});

  final Size device;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tablet = device == _tablet;
    final bezel = tablet ? 14.0 : 9.0;
    final radius = tablet ? 36.0 : 46.0;
    return AspectRatio(
      aspectRatio: device.width / device.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF05080B),
          borderRadius: BorderRadius.circular(radius + bezel),
          border: Border.all(color: const Color(0x33E6EEF4), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x88000000),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(bezel),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: FittedBox(
              child: SizedBox.fromSize(size: device, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// The app at its real screen size, with its own navigator (for the sheet)
/// and the safe-area insets of a modern phone.
class _AppScreen extends StatefulWidget {
  const _AppScreen({super.key, required this.device});

  final Size device;

  @override
  State<_AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<_AppScreen> {
  _Screen screen = _Screen.disco;
  Stage stage = Stage.silent(24);
  BuildContext? navigatorContext;

  void update(_Screen screen, Stage stage) => setState(() {
    this.screen = screen;
    this.stage = stage;
  });

  @override
  Widget build(BuildContext context) {
    final tablet = widget.device == _tablet;
    return MediaQuery(
      data: MediaQueryData(
        size: widget.device,
        padding: tablet
            ? const EdgeInsets.only(top: 24, bottom: 20)
            : const EdgeInsets.only(top: 59, bottom: 34),
        devicePixelRatio: 3,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildSugaTheme(),
        home: Builder(
          builder: (context) {
            navigatorContext = context;
            if (screen == _Screen.home) return const HomeScreen();
            return _VisualizerChrome(
              mode: switch (screen) {
                _Screen.spectrum => ColorMode.spectrum,
                _Screen.pulse => ColorMode.pulse,
                _Screen.customize => ColorMode.tiles,
                _ => ColorMode.disco,
              },
              stage: stage,
            );
          },
        ),
      ),
    );
  }
}

/// The visualizer as the app shows it, with its controls visible.
class _VisualizerChrome extends StatelessWidget {
  const _VisualizerChrome({required this.mode, required this.stage});

  final ColorMode mode;
  final Stage stage;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon) => IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: SugaColors.scrim,
        foregroundColor: SugaColors.ice,
        minimumSize: const Size.square(52),
      ),
      onPressed: () {},
      icon: Icon(icon),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Visualizer(mode: mode, stage: stage),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: button(Icons.close_rounded),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: button(Icons.tune_rounded),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ModeSwitcher(
                      mode: mode,
                      modes: ModeLineup().enabled,
                      onStep: (_) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rendering

final _boundary = GlobalKey();

Future<void> _show(
  WidgetTester t, {
  required Size canvas,
  required double ratio,
  required Widget child,
}) async {
  t.view.physicalSize = canvas;
  t.view.devicePixelRatio = ratio;
  addTearDown(t.view.reset);
  await t.runAsync(() async {
    await t.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildSugaTheme(),
        home: RepaintBoundary(
          key: _boundary,
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ),
    );
    await precacheImage(const AssetImage(_iconPath), _boundary.currentContext!);
  });
}

/// Feeds synthetic music through the real analyzer for a few seconds,
/// rebuilding at 60 fps, so stateful visuals (rings, tiles, peaks) build up.
Future<void> _drive(
  WidgetTester t, {
  required Size canvas,
  required double ratio,
  required double seconds,
  required Widget Function(Stage stage) build,
}) async {
  var stage = Stage.silent(24);
  await _show(
    t,
    canvas: canvas,
    ratio: ratio,
    child: StatefulBuilder(builder: (context, _) => build(stage)),
  );
  await _simulate(seconds, (next) async {
    stage = next;
    await t.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildSugaTheme(),
        home: RepaintBoundary(
          key: _boundary,
          child: Material(type: MaterialType.transparency, child: build(stage)),
        ),
      ),
    );
  });
}

Future<void> _play(WidgetTester t, GlobalKey innerKey, _Screen screen) async {
  final app = innerKey.currentState! as _AppScreenState;
  await _simulate(4.3, (stage) async {
    app.update(screen, stage);
    await t.pump(const Duration(milliseconds: 16));
  });

  if (screen == _Screen.customize) {
    final lineup = ModeLineup()
        .moved(ColorMode.values.indexOf(ColorMode.tiles), 1)
        .toggled(ColorMode.blackAndWhite)
        .toggled(ColorMode.level);
    unawaited(
      showModeLineupSheet(
        app.navigatorContext!,
        lineup: lineup,
        onChanged: (_) {},
      ),
    );
    for (var i = 0; i < 40; i++) {
      await t.pump(const Duration(milliseconds: 16));
    }
  }
  if (screen == _Screen.home) {
    for (var i = 0; i < 90; i++) {
      await t.pump(const Duration(milliseconds: 16));
    }
  }
}

/// Runs [seconds] of synthetic music through the analyzer, calling
/// [onFrame] with each display frame's stage.
Future<void> _simulate(
  double seconds,
  Future<void> Function(Stage stage) onFrame,
) async {
  const rate = 44100;
  final samples = _music(seconds + 0.5, rate);
  final analyzer = AudioAnalyzer(sampleRate: rate);
  final director = StageDirector(
    bandCount: analyzer.bandCount,
    framesPerSecond: analyzer.framesPerSecond,
  );
  var fed = 0;
  for (var ms = 0; ms <= seconds * 1000; ms += 16) {
    // Deliver audio in Android-sized bursts, slightly ahead of the display.
    final due = ((ms / 1000 + 0.15) * rate).round().clamp(0, samples.length);
    while (fed + 6400 <= due) {
      director.enqueue(analyzer.add(samples.sublist(fed, fed + 6400)));
      fed += 6400;
    }
    await onFrame(director.advance(Duration(milliseconds: ms)));
  }
}

/// A 120 BPM groove: kick, off-beat hats, bass line and a lead.
List<double> _music(double seconds, int rate) {
  final random = Random(3);
  return List.generate((seconds * rate).round(), (i) {
    final t = i / rate;
    final kick = t % 0.5;
    final hat = (t + 0.25) % 0.5;
    return 0.6 * exp(-kick * 25) * sin(2 * pi * 55 * kick) +
        0.15 * sin(2 * pi * 110 * t) * (0.6 + 0.4 * sin(t * 3)) +
        0.08 * sin(2 * pi * 660 * t + sin(t * 7)) +
        0.05 * sin(2 * pi * 1760 * t) * (0.5 + 0.5 * sin(t * 11)) +
        0.05 * sin(2 * pi * 5200 * t) * (0.5 + 0.5 * sin(t * 5)) +
        0.2 * exp(-hat * 60) * (random.nextDouble() - 0.5);
  });
}

Future<void> _capture(WidgetTester t, double ratio, String out) async {
  await t.runAsync(() async {
    final boundary =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: ratio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(out)..parent.createSync(recursive: true);
    file.writeAsBytesSync(png!.buffer.asUint8List());
    stdout.writeln('wrote $out (${image.width}×${image.height})');
  });
}

// ---------------------------------------------------------------------------
// Fonts

TextStyle _sora({
  required double size,
  required double weight,
  double spacing = 0,
  double height = 1.2,
}) => TextStyle(
  fontFamily: 'Sora',
  fontSize: size,
  fontVariations: [FontVariation('wght', weight)],
  letterSpacing: spacing,
  height: height,
  color: SugaColors.ice,
);

Future<void> _loadFonts() async {
  Future<ByteData> read(String path) async =>
      ByteData.sublistView(File(path).readAsBytesSync());

  final roboto = FontLoader('Roboto');
  for (final weight in ['Light', 'Regular', 'Medium', 'Bold']) {
    roboto.addFont(read('assets/fonts/Roboto-$weight.ttf'));
  }
  await roboto.load();

  await (FontLoader(
    'Sora',
  )..addFont(read('tool/store/fonts/Sora-wght.ttf'))).load();

  // Material icons ship with the Flutter SDK, next to the test runner.
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.path != dir.parent.path && !dir.path.endsWith('artifacts')) {
    dir = dir.parent;
  }
  await (FontLoader('MaterialIcons')
        ..addFont(read('${dir.path}/material_fonts/MaterialIcons-Regular.otf')))
      .load();
}
