import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_button.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/top_resource_bar.dart';

class ResourceShopScreen extends StatelessWidget {
  const ResourceShopScreen({super.key});

  static const List<_ExchangeOffer> _offers = [
    _ExchangeOffer(crystalCost: 20, oreAmount: 150, art: GameAssets.magmaContainer, label: 'Small Ore Pack'),
    _ExchangeOffer(crystalCost: 50, oreAmount: 420, art: GameAssets.resourceContainer, label: 'Large Ore Haul'),
    _ExchangeOffer(crystalCost: 100, oreAmount: 950, art: GameAssets.largeDrillingStation, label: 'Premium Ore Set'),
  ];

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
                  child: Text('Resource Exchange', style: AppTextStyles.screenTitle),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    LavaPanel(
                      borderColor: game.canClaimFreeChest ? AppColors.success : AppColors.panelBorder,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(GameAssets.resourceContainer, width: 52, height: 52),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Daily Free Chest', style: AppTextStyles.bodyStrong),
                                    Text(
                                      '${game.nextFreeChestReward.ore} ore + '
                                      '${game.nextFreeChestReward.crystals} crystals',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              LavaButton(
                                label: game.canClaimFreeChest ? 'CLAIM' : 'CLAIMED',
                                style: LavaButtonStyle.success,
                                height: 40,
                                fontSize: 13,
                                onPressed: game.canClaimFreeChest ? () => game.claimFreeChest() : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _StreakRow(
                            currentDay: game.canClaimFreeChest
                                ? game.nextFreeChestStreakDay
                                : game.profile.freeChestStreak,
                            claimedToday: !game.canClaimFreeChest,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Expedition Consumables', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 10),
                    LavaPanel(
                      child: Row(
                        children: [
                          Image.asset(GameAssets.drillBooster, width: 48, height: 48, fit: BoxFit.contain),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Drill Booster', style: AppTextStyles.bodyStrong),
                                Text(
                                  '+25% speed, -30% heat gain for one expedition',
                                  style: AppTextStyles.caption,
                                ),
                                Text('Owned: ${game.profile.drillBoosters}', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          LavaButton(
                            label: '$kDrillBoosterCrystalCost',
                            icon: Icons.auto_awesome,
                            height: 40,
                            fontSize: 13,
                            onPressed: game.profile.crystals >= kDrillBoosterCrystalCost
                                ? () => game.buyDrillBooster()
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Exchange Crystals for Ore', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 10),
                    ..._offers.map((offer) {
                      final canAfford = game.profile.crystals >= offer.crystalCost;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LavaPanel(
                          child: Row(
                            children: [
                              Image.asset(offer.art, width: 48, height: 48, fit: BoxFit.contain),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(offer.label, style: AppTextStyles.bodyStrong),
                                    Row(
                                      children: [
                                        Image.asset(GameAssets.rareOre, width: 16, height: 16),
                                        const SizedBox(width: 4),
                                        Text('+${offer.oreAmount}', style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              LavaButton(
                                label: '${offer.crystalCost}',
                                icon: Icons.auto_awesome,
                                height: 40,
                                fontSize: 13,
                                onPressed: canAfford
                                    ? () => game.exchangeCrystalsForOre(offer.crystalCost, offer.oreAmount)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the 7-day free chest streak as a row of pips, highlighting today's
/// slot so the reward growth (and the cost of missing a day) is visible at
/// a glance.
class _StreakRow extends StatelessWidget {
  final int currentDay;
  final bool claimedToday;

  const _StreakRow({required this.currentDay, required this.claimedToday});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final day = i + 1;
        final isPast = day < currentDay || (day == currentDay && claimedToday);
        final isCurrent = day == currentDay && !claimedToday;
        final color = isPast
            ? AppColors.success
            : isCurrent
                ? AppColors.emberGold
                : AppColors.panelBorder;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                Container(
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isPast || isCurrent ? 0.9 : 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: isCurrent ? Border.all(color: AppColors.emberGold, width: 1.6) : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isPast
                        ? Icons.check
                        : day == 7
                            ? Icons.star
                            : Icons.circle,
                    size: isPast || day == 7 ? 14 : 6,
                    color: isPast || isCurrent ? Colors.white : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text('D$day', style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ExchangeOffer {
  final int crystalCost;
  final int oreAmount;
  final String art;
  final String label;
  const _ExchangeOffer({
    required this.crystalCost,
    required this.oreAmount,
    required this.art,
    required this.label,
  });
}
