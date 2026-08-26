import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../models/contract.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_button.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/stat_bar.dart';
import '../../widgets/top_resource_bar.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  IconData _iconFor(ContractType type) {
    switch (type) {
      case ContractType.reachDepth:
        return Icons.arrow_downward;
      case ContractType.mineOre:
        return Icons.diamond_outlined;
      case ContractType.mineCrystals:
        return Icons.auto_awesome;
      case ContractType.defeatEnemies:
        return Icons.pest_control;
      case ContractType.findRelic:
        return Icons.temple_hindu;
      case ContractType.noOverheatExpedition:
        return Icons.ac_unit;
    }
  }

  void _claim(BuildContext context, GameProvider game, ContractInstance contract) {
    final ore = contract.rewardOre();
    final crystals = contract.rewardCrystals();
    if (!game.claimContract(contract)) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.success),
        ),
        title: Text('CONTRACT COMPLETE!', style: AppTextStyles.screenTitle.copyWith(color: AppColors.success)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(contract.title(), style: AppTextStyles.body, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(GameAssets.rareOre, width: 24, height: 24),
                const SizedBox(width: 6),
                Text('+$ore', style: AppTextStyles.bodyStrong),
                if (crystals > 0) ...[
                  const SizedBox(width: 16),
                  Image.asset(GameAssets.coolingCrystal, width: 24, height: 24),
                  const SizedBox(width: 6),
                  Text('+$crystals', style: AppTextStyles.bodyStrong),
                ],
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: LavaButton(
              label: 'NICE',
              style: LavaButtonStyle.success,
              height: 44,
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final contracts = game.profile.contracts;

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
                  child: Text('Contracts', style: AppTextStyles.screenTitle),
                ),
              ),
              Expanded(
                child: contracts.isEmpty
                    ? Center(child: Text('No active contracts.', style: AppTextStyles.body))
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: contracts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = contracts[index];
                          final ready = c.isComplete && !c.claimed;
                          return LavaPanel(
                            borderColor: c.claimed
                                ? AppColors.panelBorder
                                : (ready ? AppColors.success : AppColors.panelBorder),
                            child: Opacity(
                              opacity: c.claimed ? 0.5 : 1,
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.panelLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(_iconFor(c.type), color: AppColors.emberGold, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: Text(c.title(), style: AppTextStyles.bodyStrong)),
                                            Text(c.daily ? 'DAILY' : 'SPECIAL', style: AppTextStyles.caption),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        StatBar(
                                          percent: c.progress / c.target,
                                          color: AppColors.success,
                                          height: 8,
                                          label: '${c.progress}/${c.target}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 84,
                                    child: LavaButton(
                                      label: c.claimed ? 'DONE' : (ready ? 'CLAIM' : '+${c.rewardOre()}'),
                                      height: 38,
                                      fontSize: 12,
                                      style: ready ? LavaButtonStyle.success : LavaButtonStyle.neutral,
                                      onPressed: ready ? () => _claim(context, game, c) : null,
                                    ),
                                  ),
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
