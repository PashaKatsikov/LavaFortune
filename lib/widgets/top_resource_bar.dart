import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/assets.dart';
import '../state/game_provider.dart';

class TopResourceBar extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;

  const TopResourceBar({super.key, this.showBack = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final profile = game.profile;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          if (showBack)
            _RoundIconButton(icon: Icons.arrow_back, onTap: onBack ?? () => Navigator.maybePop(context))
          else
            const SizedBox(width: 4),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const _EnergyChip(),
                  const SizedBox(width: 8),
                  _ResourceChip(
                    image: GameAssets.rareOre,
                    label: _formatNumber(profile.ore),
                  ),
                  const SizedBox(width: 8),
                  _ResourceChip(
                    image: GameAssets.coolingCrystal,
                    label: _formatNumber(profile.crystals),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    return n.toString();
  }
}

/// Energy refills over real time, so the chip ticks on its own to show when
/// the next point arrives instead of only updating on game events.
class _EnergyChip extends StatefulWidget {
  const _EnergyChip();

  @override
  State<_EnergyChip> createState() => _EnergyChipState();
}

class _EnergyChipState extends State<_EnergyChip> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final profile = game.profile;
    final full = profile.energy >= profile.energyMax;
    return _ResourceChip(
      icon: Icons.bolt,
      iconColor: AppColors.lavaYellow,
      label: full
          ? '${profile.energy}/${profile.energyMax}'
          : '${profile.energy}/${profile.energyMax}  ${_formatCountdown(game.secondsUntilNextEnergy())}',
    );
  }
}

class _ResourceChip extends StatelessWidget {
  final IconData? icon;
  final String? image;
  final Color? iconColor;
  final String label;

  const _ResourceChip({this.icon, this.image, this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16, color: iconColor ?? Colors.white),
          if (image != null)
            SizedBox(
              width: 18,
              height: 18,
              child: Image.asset(image!, fit: BoxFit.contain),
            ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.stat),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panel,
      shape: const CircleBorder(side: BorderSide(color: AppColors.panelBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}
