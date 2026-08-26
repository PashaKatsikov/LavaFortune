import 'package:flutter/material.dart';

/// Central color palette for Lava Fortune, matching the volcanic
/// Premium Casual art direction (obsidian rock, molten lava, glowing crystals).
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0705);
  static const Color backgroundDeep = Color(0xFF050302);
  static const Color panel = Color(0xFF1A100B);
  static const Color panelLight = Color(0xFF241610);
  static const Color panelBorder = Color(0xFF4A2A15);

  static const Color lavaOrange = Color(0xFFFF6A1A);
  static const Color lavaRed = Color(0xFFE8351A);
  static const Color lavaYellow = Color(0xFFFFC93C);
  static const Color emberGold = Color(0xFFF2A93B);

  static const Color obsidian = Color(0xFF17110E);
  static const Color darkBrown = Color(0xFF2B1A10);
  static const Color deepMaroon = Color(0xFF4A1512);
  static const Color darkPurple = Color(0xFF2C1233);

  static const Color coolCyan = Color(0xFF3ED2E8);
  static const Color coolBlue = Color(0xFF3FA9F5);

  static const Color success = Color(0xFF3FBF4C);
  static const Color danger = Color(0xFFE33B2E);
  static const Color warning = Color(0xFFF2A93B);

  static const Color textPrimary = Color(0xFFF5E9DC);
  static const Color textSecondary = Color(0xFFB9A08C);
  static const Color textMuted = Color(0xFF7A6A5E);

  static const LinearGradient lavaButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFA24C), Color(0xFFE85A1A), Color(0xFFC03D10)],
  );

  static const LinearGradient greenButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5FD469), Color(0xFF2F9A3C), Color(0xFF1F7A2B)],
  );

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF231710), Color(0xFF150D08)],
  );

  static const LinearGradient screenBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B0E08), Color(0xFF0A0503), Color(0xFF060302)],
  );

  static const RadialGradient heatGlow = RadialGradient(
    colors: [Color(0x66FF6A1A), Color(0x00FF6A1A)],
  );
}
