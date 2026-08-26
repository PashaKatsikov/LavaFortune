import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/relic.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/top_resource_bar.dart';

class RelicCollectionScreen extends StatelessWidget {
  const RelicCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final owned = game.profile.ownedRelics;

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
                    Expanded(child: Text('Relic Collection', style: AppTextStyles.screenTitle)),
                    Text('${owned.length}/${kRelics.length}', style: AppTextStyles.body),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: kRelics.length,
                  itemBuilder: (context, index) {
                    final relic = kRelics[index];
                    final has = owned.contains(relic.id);
                    return LavaPanel(
                      borderColor: has ? relic.rarity.color : AppColors.panelBorder,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: has
                                ? Image.asset(relic.art, fit: BoxFit.contain)
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix(<double>[
                                      0.2, 0, 0, 0, 0,
                                      0.2, 0, 0, 0, 0,
                                      0.2, 0, 0, 0, 0,
                                      0, 0, 0, 0.5, 0,
                                    ]),
                                    child: Image.asset(relic.art, fit: BoxFit.contain),
                                  ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            has ? relic.name : '???',
                            style: AppTextStyles.sectionTitle.copyWith(fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            relic.rarity.label,
                            style: AppTextStyles.caption.copyWith(color: relic.rarity.color),
                          ),
                          if (has) ...[
                            const SizedBox(height: 4),
                            Text(
                              relic.bonusLabel,
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
