import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Text styles used across the game. Uses the default platform font with
/// heavy weights + shadows to approximate the chunky adventure-game title
/// look from the reference art without requiring a custom font asset.
class AppTextStyles {
  AppTextStyles._();

  static const _shadow = [
    Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 4),
  ];

  static TextStyle get title => const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: AppColors.emberGold,
        letterSpacing: 1.2,
        shadows: _shadow,
      );

  static TextStyle get screenTitle => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 0.8,
        shadows: _shadow,
      );

  static TextStyle get sectionTitle => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.emberGold,
        letterSpacing: 0.6,
      );

  static TextStyle get buttonLabel => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.8,
        shadows: _shadow,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyStrong => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      );

  static TextStyle get stat => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get numberLarge => const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        shadows: _shadow,
      );
}
