import 'package:flutter/material.dart';

/// Palette for gray-flow overlay chrome (boot / permission / offline).
/// Tuned to Lava Fortune's volcanic art — not the template sky-blue.
class RelayPalette {
  RelayPalette._();

  static const Color lava = Color(0xFFFF6A1A);
  static const Color ember = Color(0xFFF2A93B);
  static const Color magma = Color(0xFFE8351A);
  static const Color obsidian = Color(0xFF0A0705);
}

class RelayTheme {
  RelayTheme._();

  /// Reusable text style for crisp white titles with a soft shadow.
  static TextStyle titleStyle({double size = 28, Color color = Colors.white}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: 0.5,
      height: 1.0,
      shadows: const <Shadow>[
        Shadow(
          color: Color(0x99000000),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
  }
}
