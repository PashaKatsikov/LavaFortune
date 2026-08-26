import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/upgrade.dart';
import '../../services/audio_service.dart';
import '../../core/assets.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_button.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/stat_bar.dart';
import '../../widgets/top_resource_bar.dart';

class DrillUpgradeScreen extends StatelessWidget {
  const DrillUpgradeScreen({super.key});

  IconData _iconFor(UpgradeId id) {
    switch (id) {
      case UpgradeId.durability:
        return Icons.shield;
      case UpgradeId.coolingEfficiency:
        return Icons.ac_unit;
      case UpgradeId.maxTemperature:
        return Icons.local_fire_department;
      case UpgradeId.collisionPower:
        return Icons.bolt;
      case UpgradeId.resourceBonus:
        return Icons.inventory_2;
      case UpgradeId.rareFindChance:
        return Icons.stars;
      case UpgradeId.drillingSpeed:
        return Icons.speed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

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
                  child: Text('Upgrade Drill', style: AppTextStyles.screenTitle),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  itemCount: kUpgrades.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final upgrade = kUpgrades[index];
                    final level = game.profile.upgradeLevel(upgrade.id.name);
                    final maxed = level >= upgrade.maxLevel;
                    final cost = maxed ? 0 : upgrade.costForLevel(level);
                    final canAfford = game.profile.ore >= cost;

                    return LavaPanel(
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.panelLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(_iconFor(upgrade.id), color: AppColors.emberGold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(upgrade.name, style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
                                    ),
                                    Text('Lv. $level/${upgrade.maxLevel}', style: AppTextStyles.caption),
                                  ],
                                ),
                                Text(upgrade.description, style: AppTextStyles.caption),
                                const SizedBox(height: 6),
                                StatBar(
                                  percent: level / upgrade.maxLevel,
                                  color: AppColors.emberGold,
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 92,
                            child: LavaButton(
                              label: maxed ? 'MAX' : '$cost',
                              icon: maxed ? null : Icons.diamond_outlined,
                              height: 40,
                              fontSize: 13,
                              style: maxed ? LavaButtonStyle.neutral : LavaButtonStyle.primary,
                              onPressed: maxed || !canAfford
                                  ? null
                                  : () {
                                      if (game.purchaseUpgrade(upgrade)) {
                                        AudioService.instance.playSfx(GameAssets.sfxUpgradeComplete);
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
