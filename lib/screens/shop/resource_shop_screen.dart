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
                      child: Row(
                        children: [
                          Image.asset(GameAssets.resourceContainer, width: 52, height: 52),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily Free Chest', style: AppTextStyles.bodyStrong),
                                Text('120 ore + 15 crystals', style: AppTextStyles.caption),
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
