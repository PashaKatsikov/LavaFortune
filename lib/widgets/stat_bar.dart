import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

/// Progress values are derived from divisions that can degenerate (a zero
/// target or max stat), and NaN would throw during layout, so every fill
/// factor goes through here first.
double _safeFraction(double value) {
  if (value.isNaN) return 0;
  return value.clamp(0.0, 1.0);
}

class StatBar extends StatelessWidget {
  final double percent;
  final Color color;
  final Color backgroundColor;
  final double height;
  final Widget? leading;
  final String? label;

  const StatBar({
    super.key,
    required this.percent,
    required this.color,
    this.backgroundColor = const Color(0xFF2A1B12),
    this.height = 16,
    this.leading,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 6)],
        Expanded(
          child: Stack(
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(height / 2),
                  border: Border.all(color: AppColors.panelBorder),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _safeFraction(percent),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
                    ],
                  ),
                ),
              ),
              if (label != null)
                SizedBox(
                  height: height,
                  child: Center(
                    child: Text(
                      label!,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: height * 0.55,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CircularStatGauge extends StatelessWidget {
  final double percent;
  final Color color;
  final String label;
  final double size;

  const CircularStatGauge({
    super.key,
    required this.percent,
    required this.color,
    required this.label,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: _safeFraction(percent),
              strokeWidth: 5,
              backgroundColor: const Color(0xFF2A1B12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            label,
            style: AppTextStyles.stat.copyWith(fontSize: size * 0.22),
          ),
        ],
      ),
    );
  }
}
