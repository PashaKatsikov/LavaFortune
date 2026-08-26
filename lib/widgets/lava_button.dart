import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';

enum LavaButtonStyle { primary, success, neutral, danger }

class LavaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LavaButtonStyle style;
  final IconData? icon;
  final double height;
  final double? width;
  final double fontSize;

  const LavaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = LavaButtonStyle.primary,
    this.icon,
    this.height = 52,
    this.width,
    this.fontSize = 17,
  });

  Gradient get _gradient {
    switch (style) {
      case LavaButtonStyle.primary:
        return AppColors.lavaButtonGradient;
      case LavaButtonStyle.success:
        return AppColors.greenButtonGradient;
      case LavaButtonStyle.neutral:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A4038), Color(0xFF241D18)],
        );
      case LavaButtonStyle.danger:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE85A4A), Color(0xFF8A231A)],
        );
    }
  }

  Color get _borderColor {
    switch (style) {
      case LavaButtonStyle.primary:
        return const Color(0xFFFFD59A);
      case LavaButtonStyle.success:
        return const Color(0xFFAEF0A8);
      case LavaButtonStyle.neutral:
        return const Color(0xFF6B5D50);
      case LavaButtonStyle.danger:
        return const Color(0xFFFFB2A0);
    }
  }

  bool get _disabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _disabled ? 0.45 : 1,
      child: SizedBox(
        height: height,
        width: width,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _disabled
                ? null
                : () {
                    AudioService.instance.click();
                    HapticsService.instance.light();
                    onPressed!();
                  },
            child: Container(
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: width != null && width! < 100 ? 6 : 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: fontSize + 4),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.buttonLabel.copyWith(fontSize: fontSize),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
