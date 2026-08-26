import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/enemy.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/top_resource_bar.dart';

class CreatureCollectionScreen extends StatelessWidget {
  const CreatureCollectionScreen({super.key});

  Color _categoryColor(EnemyCategory c) {
    switch (c) {
      case EnemyCategory.normal:
        return AppColors.textSecondary;
      case EnemyCategory.special:
        return AppColors.coolCyan;
      case EnemyCategory.elite:
        return AppColors.danger;
      case EnemyCategory.boss:
        return AppColors.emberGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final defeated = game.profile.defeatedCounts;
    final foundCount = kEnemies.where((e) => (defeated[e.id] ?? 0) > 0).length;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              const TopResourceBar(showBack: true),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text('Bestiary', style: AppTextStyles.screenTitle)),
                    Text('$foundCount/${kEnemies.length}', style: AppTextStyles.body),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: kEnemies.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final enemy = kEnemies[index];
                    final count = defeated[enemy.id] ?? 0;
                    final found = count > 0;
                    return LavaPanel(
                      borderColor: found ? _categoryColor(enemy.category) : AppColors.panelBorder,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: found
                                ? Image.asset(enemy.art, fit: BoxFit.contain)
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix(<double>[
                                      0, 0, 0, 0, 20,
                                      0, 0, 0, 0, 20,
                                      0, 0, 0, 0, 20,
                                      0, 0, 0, 1, 0,
                                    ]),
                                    child: Image.asset(enemy.art, fit: BoxFit.contain),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  found ? enemy.name : '???',
                                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
                                ),
                                Text(
                                  enemy.category.name.toUpperCase(),
                                  style: AppTextStyles.caption.copyWith(color: _categoryColor(enemy.category)),
                                ),
                                if (found)
                                  Text(
                                    enemy.description,
                                    style: AppTextStyles.caption,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          if (found)
                            Text('x$count', style: AppTextStyles.bodyStrong)
                          else
                            const Icon(Icons.lock, color: AppColors.textMuted),
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
