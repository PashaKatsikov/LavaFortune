import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../models/drill.dart';
import '../../models/drill_head.dart';
import '../../state/game_provider.dart';
import '../../widgets/drill_art.dart';
import '../../widgets/lava_button.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/stat_bar.dart';
import '../../widgets/top_resource_bar.dart';
import '../collection/relic_collection_screen.dart';
import 'drill_head_select_screen.dart';
import 'drill_upgrade_screen.dart';

class WorkshopScreen extends StatelessWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final drill = drillById(game.profile.selectedDrill);
    final head = drillHeadById(game.profile.selectedDrillHead);
    final stats = game.effectiveStats;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              const TopResourceBar(showBack: true),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Workshop', style: AppTextStyles.screenTitle),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: Column(
                    children: [
                      LavaPanel(
                        child: Column(
                          children: [
                            DrillArt(drill: drill, height: 150),
                            const SizedBox(height: 8),
                            Text(drill.name, style: AppTextStyles.sectionTitle),
                            Text('Head: ${head.name}', style: AppTextStyles.caption),
                            const SizedBox(height: 12),
                            StatBar(
                              percent: 1,
                              color: AppColors.danger,
                              leading: const Icon(Icons.favorite, color: AppColors.danger, size: 16),
                              label: '${stats.maxHp.round()} HP',
                            ),
                            const SizedBox(height: 8),
                            StatBar(
                              percent: 1,
                              color: AppColors.lavaOrange,
                              leading: const Icon(Icons.local_fire_department, color: AppColors.lavaOrange, size: 16),
                              label: '${stats.maxHeat.round()} max heat',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _miniStat(Icons.diamond_outlined, GameAssets.rareOre, '${game.profile.ore}'),
                                _miniStat(Icons.auto_awesome, GameAssets.coolingCrystal, '${game.profile.crystals}'),
                                _miniStat(Icons.temple_hindu, null, '${game.profile.ownedRelics.length}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: LavaButton(
                              label: 'UPGRADE',
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const DrillUpgradeScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LavaButton(
                              label: 'DRILL HEAD',
                              style: LavaButtonStyle.neutral,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const DrillHeadSelectScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LavaButton(
                        label: 'RELICS',
                        style: LavaButtonStyle.neutral,
                        width: double.infinity,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RelicCollectionScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData fallbackIcon, String? asset, String value) {
    return Column(
      children: [
        asset != null
            ? Image.asset(asset, width: 26, height: 26, fit: BoxFit.contain)
            : Icon(fallbackIcon, color: AppColors.emberGold, size: 24),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyStrong),
      ],
    );
  }
}
