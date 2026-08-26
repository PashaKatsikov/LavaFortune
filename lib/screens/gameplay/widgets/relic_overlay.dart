import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../models/relic.dart';
import '../../../widgets/lava_button.dart';
import '../../../widgets/lava_panel.dart';

class RelicOverlay extends StatelessWidget {
  final RelicDef relic;
  final VoidCallback onContinue;

  const RelicOverlay({super.key, required this.relic, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      alignment: Alignment.center,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: LavaPanel(
            borderColor: relic.rarity.color,
            borderWidth: 2,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ANCIENT RELIC FOUND!',
                  style: AppTextStyles.screenTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: relic.rarity.color.withValues(alpha: 0.6), blurRadius: 30),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(relic.art, height: 120, fit: BoxFit.contain),
                ),
                const SizedBox(height: 14),
                Text(relic.name, style: AppTextStyles.sectionTitle, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(
                  relic.rarity.label,
                  style: AppTextStyles.caption.copyWith(color: relic.rarity.color),
                ),
                const SizedBox(height: 10),
                Text(relic.description, style: AppTextStyles.body, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  relic.bonusLabel,
                  style: AppTextStyles.bodyStrong.copyWith(color: AppColors.success),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                LavaButton(
                  label: 'COLLECT',
                  style: LavaButtonStyle.success,
                  width: double.infinity,
                  onPressed: onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
