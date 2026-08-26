import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../models/drill.dart';
import '../../models/zone.dart';
import '../../services/audio_service.dart';
import '../../state/game_provider.dart';
import '../../widgets/drill_art.dart';
import '../../widgets/lava_button.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/stat_bar.dart';
import '../../widgets/top_resource_bar.dart';
import '../gameplay/gameplay_screen.dart';

const int kExpeditionEnergyCost = 1;

class DrillSelectScreen extends StatefulWidget {
  final ZoneId zoneId;
  const DrillSelectScreen({super.key, required this.zoneId});

  @override
  State<DrillSelectScreen> createState() => _DrillSelectScreenState();
}

class _DrillSelectScreenState extends State<DrillSelectScreen> {
  late DrillId _selected;
  bool _useBooster = false;

  @override
  void initState() {
    super.initState();
    final game = context.read<GameProvider>();
    _selected = game.profile.selectedDrill;
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final zone = zoneById(widget.zoneId);
    final hasEnergy = game.profile.energy >= kExpeditionEnergyCost;
    final hasBooster = game.profile.drillBoosters > 0;
    final boosting = _useBooster && hasBooster;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              const TopResourceBar(showBack: true),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Drill', style: AppTextStyles.screenTitle),
                    Text('Expedition: ${zone.name}',
                        style: AppTextStyles.body.copyWith(color: zone.accentColor)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: kDrills.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final drill = kDrills[index];
                    final unlocked = game.isDrillUnlocked(drill.id);
                    final isSelected = drill.id == _selected;
                    return _DrillCard(
                      drill: drill,
                      unlocked: unlocked,
                      selected: isSelected,
                      onTap: () {
                        if (unlocked) {
                          setState(() => _selected = drill.id);
                        } else {
                          _showUnlockDialog(context, game, drill);
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: GestureDetector(
                  onTap: hasBooster ? () => setState(() => _useBooster = !_useBooster) : null,
                  child: LavaPanel(
                    borderColor: boosting ? AppColors.emberGold : AppColors.panelBorder,
                    borderWidth: boosting ? 2.0 : 1.2,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Opacity(
                      opacity: hasBooster ? 1 : 0.5,
                      child: Row(
                        children: [
                          Image.asset(GameAssets.drillBooster, width: 40, height: 40, fit: BoxFit.contain),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Drill Booster', style: AppTextStyles.bodyStrong),
                                Text(
                                  hasBooster
                                      ? '+25% speed, -30% heat gain this run  (owned: ${game.profile.drillBoosters})'
                                      : 'None owned - buy in the Resource Shop',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: boosting,
                            onChanged: hasBooster ? (v) => setState(() => _useBooster = v ?? false) : null,
                            activeColor: AppColors.emberGold,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Material(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LavaButton(
                        label: hasEnergy ? 'START (-$kExpeditionEnergyCost)' : 'NOT ENOUGH ENERGY',
                        icon: hasEnergy ? Icons.bolt : null,
                        fontSize: hasEnergy ? 17 : 14,
                        style: LavaButtonStyle.success,
                        onPressed: hasEnergy
                            ? () {
                                game.selectDrill(_selected);
                                game.spendEnergy(kExpeditionEnergyCost);
                                final consumedBooster = boosting && game.consumeDrillBooster();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => GameplayScreen(
                                      zoneId: widget.zoneId,
                                      useBooster: consumedBooster,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnlockDialog(BuildContext context, GameProvider game, DrillDef drill) {
    final canProgress = game.canUnlockDrillProgress(drill);
    final canAfford = game.profile.ore >= drill.unlockOreCost &&
        game.profile.crystals >= drill.unlockCrystalCost;
    final priceText = '${drill.unlockOreCost} ore'
        '${drill.unlockCrystalCost > 0 ? ' + ${drill.unlockCrystalCost} crystals' : ''}';

    String message;
    if (!canProgress) {
      message = 'Reach ${drill.unlockDepthRequirement}m in '
          '${_zoneGateName(drill.unlockZone)} to unlock this drill.';
    } else if (!canAfford) {
      message = 'You need $priceText to unlock this drill.';
    } else {
      message = 'Unlock for $priceText?';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.panelBorder),
        ),
        title: Text(drill.name, style: AppTextStyles.sectionTitle),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (canProgress && canAfford)
            TextButton(
              onPressed: () {
                if (game.unlockDrill(drill)) {
                  AudioService.instance.playSfx(GameAssets.sfxUpgradeComplete);
                  setState(() => _selected = drill.id);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Unlock', style: TextStyle(color: AppColors.success)),
            ),
        ],
      ),
    );
  }

  String _zoneGateName(ZoneGate gate) {
    switch (gate) {
      case ZoneGate.none:
        return 'any zone';
      case ZoneGate.upperTunnels:
        return zoneById(ZoneId.upperTunnels).name;
      case ZoneGate.magmaCaves:
        return zoneById(ZoneId.magmaCaves).name;
      case ZoneGate.crystalDepths:
        return zoneById(ZoneId.crystalDepths).name;
    }
  }
}

class _DrillCard extends StatelessWidget {
  final DrillDef drill;
  final bool unlocked;
  final bool selected;
  final VoidCallback onTap;

  const _DrillCard({
    required this.drill,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LavaPanel(
        borderColor: selected ? AppColors.emberGold : AppColors.panelBorder,
        borderWidth: selected ? 2.2 : 1.2,
        child: Opacity(
          opacity: unlocked ? 1 : 0.55,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrillArt(drill: drill, width: 72, height: 72),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(drill.name, style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                        else if (!unlocked)
                          const Icon(Icons.lock, color: AppColors.textMuted, size: 18),
                      ],
                    ),
                    Text(drill.tagline, style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    _miniStat('Durability', drill.baseHp / 200, AppColors.success),
                    const SizedBox(height: 4),
                    _miniStat('Speed', drill.baseSpeed / 1.5, AppColors.coolCyan),
                    const SizedBox(height: 4),
                    _miniStat('Heat Resistance', 1 - (drill.heatGainMultiplier / 1.4), AppColors.lavaOrange),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 92, child: Text(label, style: AppTextStyles.caption)),
        Expanded(child: StatBar(percent: value, color: color, height: 8)),
      ],
    );
  }
}
