import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../models/zone.dart';
import '../../services/audio_service.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/top_resource_bar.dart';
import '../expedition/expedition_select_screen.dart';

class IslandMapScreen extends StatelessWidget {
  const IslandMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      body: ScreenBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.35,
              child: Image.asset(GameAssets.bgVolcanoHeart, fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                children: [
                  const TopResourceBar(showBack: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Text('Volcanic Island', style: AppTextStyles.screenTitle),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      reverse: true,
                      itemCount: kZones.length,
                      itemBuilder: (context, index) {
                        final zone = kZones[index];
                        final unlocked = game.isZoneUnlocked(zone.id);
                        final canUnlock = game.canUnlockZone(zone);
                        final best = game.profile.bestDepthByZone[zone.id];
                        final alignRight = index.isEven;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment:
                                alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.72,
                                child: _ZoneNode(
                                  zone: zone,
                                  unlocked: unlocked,
                                  canUnlock: canUnlock,
                                  bestDepth: best,
                                  onTap: () => _onZoneTap(context, zone, unlocked, canUnlock, game),
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
          ],
        ),
      ),
    );
  }

  void _onZoneTap(
    BuildContext context,
    ZoneDef zone,
    bool unlocked,
    bool canUnlock,
    GameProvider game,
  ) {
    if (unlocked) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ExpeditionSelectScreen(initialZoneId: zone.id)),
      );
      return;
    }
    final canAfford = game.canAffordZoneUnlock(zone);
    String message;
    if (!canUnlock) {
      message = 'Reach ${zone.unlockDepthRequirement}m in the previous zone '
          'to unlock ${zone.name}.';
    } else if (!canAfford) {
      message = 'You need ${zone.unlockOreCost} ore to unlock ${zone.name}.';
    } else {
      message = 'Unlock ${zone.name} for ${zone.unlockOreCost} ore?';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.panelBorder),
        ),
        title: Text(zone.name, style: AppTextStyles.sectionTitle),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (canUnlock && canAfford)
            TextButton(
              onPressed: () {
                game.unlockZone(zone);
                AudioService.instance.playSfx(GameAssets.sfxUpgradeComplete);
                Navigator.pop(ctx);
              },
              child: const Text('Unlock', style: TextStyle(color: AppColors.success)),
            ),
        ],
      ),
    );
  }
}

class _ZoneNode extends StatelessWidget {
  final ZoneDef zone;
  final bool unlocked;
  final bool canUnlock;
  final int? bestDepth;
  final VoidCallback onTap;

  const _ZoneNode({
    required this.zone,
    required this.unlocked,
    required this.canUnlock,
    required this.bestDepth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LavaPanel(
        borderColor: unlocked ? zone.accentColor : AppColors.panelBorder,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: unlocked ? 0.55 : 0.25,
                  child: Image.asset(zone.background, fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.15), Colors.black.withValues(alpha: 0.8)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            zone.name,
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: unlocked ? zone.accentColor : AppColors.textMuted,
                            ),
                          ),
                        ),
                        Icon(
                          unlocked ? Icons.lock_open : Icons.lock,
                          size: 18,
                          color: unlocked ? AppColors.success : AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      zone.maxDepth == 999999
                          ? 'Recommended depth: ${zone.minDepth}m+'
                          : 'Recommended depth: ${zone.minDepth}-${zone.maxDepth}m',
                      style: AppTextStyles.caption,
                    ),
                    if (bestDepth != null) ...[
                      const SizedBox(height: 2),
                      Text('Best: ${bestDepth}m', style: AppTextStyles.caption.copyWith(color: AppColors.emberGold)),
                    ],
                    if (!unlocked) ...[
                      const SizedBox(height: 6),
                      Text(
                        canUnlock
                            ? 'Unlock for ${zone.unlockOreCost} ore'
                            : 'Requires ${zone.unlockDepthRequirement}m in previous zone',
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                      ),
                    ],
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
