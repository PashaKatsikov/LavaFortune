import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../core/assets.dart';
import '../../../models/run_state.dart';
import '../../../widgets/stat_bar.dart';

class GameplayHud extends StatelessWidget {
  final RunState run;
  final VoidCallback onPause;
  final VoidCallback onVent;

  const GameplayHud({super.key, required this.run, required this.onPause, required this.onVent});

  Color get _heatColor {
    if (run.heatPercent > 0.8) return AppColors.danger;
    if (run.heatPercent > 0.5) return AppColors.warning;
    return AppColors.lavaOrange;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RoundButton(icon: Icons.pause, onTap: onPause),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.panel.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.panelBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('DEPTH', style: AppTextStyles.caption),
                      Text('${run.depthMeters}m', style: AppTextStyles.numberLarge.copyWith(fontSize: 20)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircularStatGauge(
                percent: run.heatPercent,
                color: _heatColor,
                label: '${(run.heatPercent * 100).round()}%',
              ),
              const SizedBox(width: 10),
              _RoundButton(
                icon: Icons.ac_unit,
                onTap: run.ventUsed || run.status != RunStatus.running ? null : onVent,
                dimmed: run.ventUsed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatBar(
            percent: run.hpPercent,
            color: AppColors.danger,
            leading: const Icon(Icons.favorite, color: AppColors.danger, size: 16),
            label: '${run.hp.round()}/${run.hpMax.round()}',
            height: 16,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HaulChip(asset: GameAssets.rareOre, value: run.oreCollected),
              const SizedBox(width: 10),
              _HaulChip(asset: GameAssets.coolingCrystal, value: run.crystalsCollected),
              if (run.boosterActive) ...[
                const SizedBox(width: 10),
                const _BoosterBadge(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows what the current run has banked so far, which is the information the
/// extract-or-continue decision hinges on.
class _HaulChip extends StatelessWidget {
  final String asset;
  final int value;

  const _HaulChip({required this.asset, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, width: 16, height: 16, fit: BoxFit.contain),
          const SizedBox(width: 6),
          Text('$value', style: AppTextStyles.stat),
        ],
      ),
    );
  }
}

/// Reminds the player that this run's heat gain is reduced and speed is
/// boosted, so the risk/reward math they see on screen differs from usual.
class _BoosterBadge extends StatelessWidget {
  const _BoosterBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.emberGold.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emberGold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(GameAssets.drillBooster, width: 16, height: 16, fit: BoxFit.contain),
          const SizedBox(width: 6),
          Text('BOOST', style: AppTextStyles.stat.copyWith(color: AppColors.emberGold)),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool dimmed;
  const _RoundButton({required this.icon, required this.onTap, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: Material(
        color: AppColors.panel.withValues(alpha: 0.85),
        shape: const CircleBorder(side: BorderSide(color: AppColors.panelBorder)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }
}
