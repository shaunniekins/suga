import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suga/visuals/stage.dart';

/// A mosaic of tiles: the louder the room, the more tiles light up, and
/// every beat sets off a burst. Lit tiles fade back to dark.
class TilesView extends StatefulWidget {
  const TilesView({super.key, required this.stage});

  final Stage stage;

  @override
  State<TilesView> createState() => _TilesViewState();
}

class _TilesViewState extends State<TilesView> {
  static const _targetTileSize = 64.0;
  static const _baseColor = Color(0xFF111B23);
  static const _fadeSeconds = 0.35;

  final _random = Random();
  List<Color> _colors = const [];
  int _columns = 0;
  int _rows = 0;
  int _version = 0;

  @override
  void didUpdateWidget(TilesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final s = widget.stage;
    if (_colors.isEmpty) return;

    final dt = (s.time - oldWidget.stage.time).clamp(0.0, 0.1);
    final fade = 1 - exp(-dt / _fadeSeconds);
    for (var i = 0; i < _colors.length; i++) {
      _colors[i] = Color.lerp(_colors[i], _baseColor, fade)!;
    }

    // Steady sparkle with loudness, plus a burst on each beat.
    var lit = (s.level * _colors.length * 1.5 * dt).round();
    if (s.beats != oldWidget.stage.beats) lit += _colors.length ~/ 4;
    for (var i = 0; i < lit; i++) {
      _colors[_random.nextInt(_colors.length)] = s.color(_random.nextInt(5));
    }
    _version++;
  }

  void _fitGrid(Size size) {
    final columns = max(1, (size.width / _targetTileSize).round());
    final rows = max(1, (size.height / _targetTileSize).round());
    if (columns == _columns && rows == _rows) return;

    _columns = columns;
    _rows = rows;
    _colors = List.filled(columns * rows, _baseColor);
    _version++;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _fitGrid(constraints.biggest);
          return CustomPaint(
            size: constraints.biggest,
            painter: _TilesPainter(_colors, _columns, _rows, _version),
          );
        },
      ),
    );
  }
}

class _TilesPainter extends CustomPainter {
  _TilesPainter(this.colors, this.columns, this.rows, this.version);

  final List<Color> colors;
  final int columns;
  final int rows;
  final int version;

  @override
  void paint(Canvas canvas, Size size) {
    final tileWidth = size.width / columns;
    final tileHeight = size.height / rows;
    final paint = Paint();

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        paint.color = colors[row * columns + column];
        final rect = Rect.fromLTWH(
          column * tileWidth,
          row * tileHeight,
          tileWidth,
          tileHeight,
        ).deflate(1);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TilesPainter oldDelegate) =>
      oldDelegate.version != version;
}
