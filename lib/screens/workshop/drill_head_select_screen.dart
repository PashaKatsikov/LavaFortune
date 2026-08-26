import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../models/drill_head.dart';
import '../../services/audio_service.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/top_resource_bar.dart';

class DrillHeadSelectScreen extends StatelessWidget {
  const DrillHeadSelectScreen({super.key});

  void _showUnlockDialog(BuildContext context, GameProvider game, DrillHeadDef head) {
    final canAfford = game.profile.ore >= head.unlockOreCost;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.panelBorder),
        ),
        title: Text(head.name, style: AppTextStyles.sectionTitle),
        content: Text(
          canAfford
              ? 'Buy this drill head for ${head.unlockOreCost} ore?'
              : 'You need ${head.unlockOreCost} ore to buy this drill head.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (canAfford)
            TextButton(
              onPressed: () {
                if (game.unlockDrillHead(head)) {
                  game.selectDrillHead(head.id);
                  AudioService.instance.playSfx(GameAssets.sfxUpgradeComplete);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Buy', style: TextStyle(color: AppColors.success)),
            ),
        ],
      ),
    );
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
                  child: Text('Drill Head', style: AppTextStyles.screenTitle),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: kDrillHeads.length,
                  itemBuilder: (context, index) {
                    final head = kDrillHeads[index];
                    final unlocked = game.profile.unlockedDrillHeads.contains(head.id);
                    final selected = game.profile.selectedDrillHead == head.id;
                    return GestureDetector(
                      onTap: () {
                        if (unlocked) {
                          game.selectDrillHead(head.id);
                          AudioService.instance.playSfx(GameAssets.sfxMenuSelect);
                        } else {
                          _showUnlockDialog(context, game, head);
                        }
                      },
                      child: LavaPanel(
                        borderColor: selected ? AppColors.emberGold : AppColors.panelBorder,
                        borderWidth: selected ? 2.2 : 1.2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: head.color.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(color: head.color),
                              ),
                              child: Icon(head.icon, color: head.color, size: 28),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              head.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.sectionTitle.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            if (head.bonusValue > 0)
                              Text(
                                head.bonusLabel,
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 8),
                            if (selected)
                              const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                            else if (!unlocked)
                              Text(
                                '${head.unlockOreCost} ore',
                                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                              )
                            else
                              Text('Tap to equip', style: AppTextStyles.caption),
                          ],
                        ),
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
