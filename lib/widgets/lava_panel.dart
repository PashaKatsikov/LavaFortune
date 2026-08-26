import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// A bordered, gradient-filled panel matching the game's UI card style.
class LavaPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final Gradient? gradient;

  const LavaPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
    this.borderWidth = 1.4,
    this.radius = 16,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.panelGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.panelBorder, width: borderWidth),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class ScreenBackground extends StatelessWidget {
  final Widget child;
  const ScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.screenBackgroundGradient),
      child: child,
    );
  }
}
