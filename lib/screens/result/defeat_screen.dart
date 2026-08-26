import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../models/drill.dart';
import '../../models/run_state.dart';
import '../../state/game_provider.dart';
import '../../widgets/drill_art.dart';
import '../../widgets/lava_button.dart';
import '../../widgets/lava_panel.dart';
import '../main_menu/main_menu_screen.dart';
import '../workshop/workshop_screen.dart';

class DefeatScreen extends StatelessWidget {
  final RunState run;
  const DefeatScreen({super.key, required this.run});

  String get _reasonText {
    switch (run.defeatReason) {
      case DefeatReason.overheat:
        return 'Critical Overheat';
      case DefeatReason.destroyed:
        return 'Drill Destroyed';
      case DefeatReason.none:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LavaPanel(
                  borderColor: AppColors.danger,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'EXPEDITION FAILED',
                        style: AppTextStyles.screenTitle.copyWith(color: AppColors.danger),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('Reason:', style: AppTextStyles.caption),
                      Text(_reasonText, style: AppTextStyles.bodyStrong),
                      const SizedBox(height: 20),
                      ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.6, 0, 0, 0, 0,
                          0, 0.2, 0, 0, 0,
                          0, 0, 0.2, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: DrillArt(
                          drill: drillById(context.read<GameProvider>().profile.selectedDrill),
                          height: 130,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Reached depth: ${run.depthMeters}m', style: AppTextStyles.body),
                      const SizedBox(height: 4),
                      Text(
                        'Resources secured before failure are kept.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _chip(GameAssets.rareOre, '+${run.oreCollected}'),
                          _chip(GameAssets.coolingCrystal, '+${run.crystalsCollected}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                LavaButton(
                  label: 'TO WORKSHOP',
                  style: LavaButtonStyle.success,
                  width: double.infinity,
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                      (route) => false,
                    );
                    navigator.push(
                      MaterialPageRoute(builder: (_) => const WorkshopScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                    (route) => false,
                  ),
                  child: const Text(
                    'Back to Main Menu',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String asset, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 22, height: 22, fit: BoxFit.contain),
        const SizedBox(width: 6),
        Text(value, style: AppTextStyles.bodyStrong),
      ],
    );
  }
}
