import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/zone.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_button.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/top_resource_bar.dart';
import 'drill_select_screen.dart';

class ExpeditionSelectScreen extends StatefulWidget {
  final ZoneId? initialZoneId;
  const ExpeditionSelectScreen({super.key, this.initialZoneId});

  @override
  State<ExpeditionSelectScreen> createState() => _ExpeditionSelectScreenState();
}

class _ExpeditionSelectScreenState extends State<ExpeditionSelectScreen> {
  late ZoneId _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialZoneId ?? ZoneId.upperTunnels;
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final unlocked = game.isZoneUnlocked(_selected);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              const TopResourceBar(showBack: true),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Text('Select Expedition', style: AppTextStyles.screenTitle),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: kZones.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final zone = kZones[index];
                    final isUnlocked = game.isZoneUnlocked(zone.id);
                    final isSelected = zone.id == _selected;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = zone.id),
                      child: LavaPanel(
                        borderColor: isSelected ? zone.accentColor : AppColors.panelBorder,
                        borderWidth: isSelected ? 2.2 : 1.2,
                        child: Opacity(
                          opacity: isUnlocked ? 1 : 0.5,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  zone.background,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      zone.name,
                                      style: AppTextStyles.sectionTitle.copyWith(
                                        color: zone.accentColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      zone.maxDepth == 999999
                                          ? 'Recommended depth: ${zone.minDepth}m+'
                                          : 'Recommended depth: ${zone.minDepth}-${zone.maxDepth}m',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isUnlocked) const Icon(Icons.lock, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: LavaButton(
                  label: unlocked ? 'SELECT' : 'ZONE LOCKED',
                  width: double.infinity,
                  onPressed: unlocked
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DrillSelectScreen(zoneId: _selected),
                            ),
                          )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
