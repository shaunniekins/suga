import 'package:flutter/painting.dart';

/// A set of five club-light colors. The stage rotates through a palette on
/// every beat and moves to the next palette every [Stage.beatsPerPalette].
class Palette {
  const Palette(this.name, this.colors);

  final String name;
  final List<Color> colors;
}

const List<Palette> palettes = [
  Palette('Neon', [
    Color(0xFFFF2BD6),
    Color(0xFF7A2BFF),
    Color(0xFF2B8CFF),
    Color(0xFF00F0FF),
    Color(0xFF39FF88),
  ]),
  Palette('Sunset', [
    Color(0xFFFF3D5A),
    Color(0xFFFF7A2B),
    Color(0xFFFFC12B),
    Color(0xFFFF2B8C),
    Color(0xFFB42BFF),
  ]),
  Palette('Acid', [
    Color(0xFFB6FF00),
    Color(0xFF00FF6A),
    Color(0xFFFFF200),
    Color(0xFF00E5FF),
    Color(0xFFFF00C8),
  ]),
  Palette('Ocean', [
    Color(0xFF00E5FF),
    Color(0xFF2B7BFF),
    Color(0xFF6A2BFF),
    Color(0xFF00FFB2),
    Color(0xFF2BD9FF),
  ]),
  Palette('Fire', [
    Color(0xFFFF2200),
    Color(0xFFFF6A00),
    Color(0xFFFFB300),
    Color(0xFFFFE600),
    Color(0xFFFF0055),
  ]),
];

/// Classic meter scale for the Level mode: green while comfortable, red
/// when loud.
const List<Color> meterSpectrum = [
  Color(0xFF2FD07B),
  Color(0xFF9BE33A),
  Color(0xFFFFD23F),
  Color(0xFFFF8A3D),
  Color(0xFFFF4A3D),
];

/// The color at [t] (0–1) along evenly spaced [stops].
Color colorAt(List<Color> stops, double t) {
  final scaled = t.clamp(0.0, 1.0) * (stops.length - 1);
  final i = scaled.floor().clamp(0, stops.length - 2);
  return Color.lerp(stops[i], stops[i + 1], scaled - i)!;
}
