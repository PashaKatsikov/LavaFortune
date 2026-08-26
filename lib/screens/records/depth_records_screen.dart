import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/zone.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/top_resource_bar.dart';

class DepthRecordsScreen extends StatelessWidget {
  const DepthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final profile = game.profile;

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
                  child: Text('Depth Records', style: AppTextStyles.screenTitle),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: LavaPanel(
                  borderColor: AppColors.emberGold,
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: AppColors.emberGold, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Best Overall Depth', style: AppTextStyles.caption),
                            Text('${profile.bestOverallDepth}m', style: AppTextStyles.numberLarge),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${profile.totalRuns}', style: AppTextStyles.bodyStrong),
                          Text('expeditions', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: kZones.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final zone = kZones[index];
                    final best = profile.bestDepthByZone[zone.id] ?? 0;
                    final unlocked = game.isZoneUnlocked(zone.id);
                    return LavaPanel(
                      borderColor: unlocked ? zone.accentColor : AppColors.panelBorder,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Opacity(
                              opacity: unlocked ? 1 : 0.4,
                              child: Image.asset(zone.background, width: 44, height: 44, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(zone.name, style: AppTextStyles.bodyStrong),
                          ),
                          Text(
                            unlocked ? '${best}m' : '—',
                            style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
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
