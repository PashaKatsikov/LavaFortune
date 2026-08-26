import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../models/run_state.dart';
import '../../widgets/lava_button.dart';
import '../../widgets/lava_panel.dart';
import '../main_menu/main_menu_screen.dart';
import '../workshop/workshop_screen.dart';

class ExpeditionResultScreen extends StatelessWidget {
  final RunState run;
  const ExpeditionResultScreen({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text('EXPEDITION COMPLETE!', style: AppTextStyles.screenTitle, textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text('Resources secured and returned to the surface.',
                    style: AppTextStyles.body, textAlign: TextAlign.center),
                if (run.bossDefeated) ...[
                  const SizedBox(height: 12),
                  LavaPanel(
                    borderColor: AppColors.lavaYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Image.asset(GameAssets.finalBoss, width: 40, height: 40, fit: BoxFit.contain),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The Volcanic Monster has been slain!',
                            style: AppTextStyles.bodyStrong.copyWith(color: AppColors.lavaYellow),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: LavaPanel(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _statRow('Maximum Depth', '${run.depthMeters}m', Icons.arrow_downward),
                          _statRow('Ore Mined', '${run.oreCollected}', Icons.diamond_outlined),
                          _statRow('Crystals', '${run.crystalsCollected}', Icons.auto_awesome),
                          _statRow('Relics Found', '${run.relicsFound.length}', Icons.temple_hindu),
                          _statRow('Enemies Defeated', '${run.enemiesDefeated}', Icons.pest_control),
                          const Divider(color: AppColors.panelBorder, height: 28),
                          Text('REWARDS', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _rewardChip(GameAssets.rareOre, '+${run.oreCollected}'),
                              _rewardChip(GameAssets.coolingCrystal, '+${run.crystalsCollected}'),
                              if (run.relicsFound.isNotEmpty)
                                _rewardChip(run.relicsFound.first.art, '+${run.relicsFound.length}'),
                            ],
                          ),
                          if (run.log.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            for (final entry in run.log.take(6))
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '• ${entry.text}',
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LavaButton(
                  label: 'CLAIM',
                  style: LavaButtonStyle.success,
                  width: double.infinity,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
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
                  child: const Text('Go to Workshop', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.emberGold),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.bodyStrong),
        ],
      ),
    );
  }

  Widget _rewardChip(String asset, String value) {
    return Column(
      children: [
        LavaPanel(
          radius: 12,
          padding: const EdgeInsets.all(10),
          child: Image.asset(asset, width: 34, height: 34, fit: BoxFit.contain),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyStrong),
      ],
    );
  }
}
