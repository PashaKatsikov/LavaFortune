import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/assets.dart';
import '../../services/audio_service.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_button.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/top_resource_bar.dart';
import '../collection/creature_collection_screen.dart';
import '../collection/relic_collection_screen.dart';
import '../contracts/contracts_screen.dart';
import '../map/island_map_screen.dart';
import '../records/depth_records_screen.dart';
import '../settings/settings_screen.dart';
import '../shop/resource_shop_screen.dart';
import '../workshop/workshop_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    if (!game.loaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ScreenBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.55,
              child: Image.asset(GameAssets.bgUpperTunnels, fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDeep.withValues(alpha: 0.55),
                    AppColors.backgroundDeep.withValues(alpha: 0.85),
                    AppColors.backgroundDeep,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const TopResourceBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Image.asset(GameAssets.gameLogo, height: 190),
                          const SizedBox(height: 8),
                          Image.asset(GameAssets.drillMain, height: 130),
                          const SizedBox(height: 24),
                          LavaButton(
                            label: 'PLAY',
                            fontSize: 20,
                            height: 58,
                            width: double.infinity,
                            onPressed: () => _push(const IslandMapScreen()),
                          ),
                          const SizedBox(height: 14),
                          LavaButton(
                            label: 'WORKSHOP',
                            style: LavaButtonStyle.neutral,
                            width: double.infinity,
                            onPressed: () => _push(const WorkshopScreen()),
                          ),
                          const SizedBox(height: 12),
                          LavaButton(
                            label: 'CONTRACTS',
                            style: LavaButtonStyle.neutral,
                            width: double.infinity,
                            onPressed: () => _push(const ContractsScreen()),
                          ),
                          const SizedBox(height: 12),
                          LavaButton(
                            label: 'DEPTH RECORDS',
                            style: LavaButtonStyle.neutral,
                            width: double.infinity,
                            onPressed: () => _push(const DepthRecordsScreen()),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _IconMenuButton(
                                icon: Icons.settings,
                                label: 'Settings',
                                onTap: () => _push(const SettingsScreen()),
                              ),
                              const SizedBox(width: 16),
                              _IconMenuButton(
                                icon: Icons.diamond,
                                label: 'Relics',
                                onTap: () => _push(const RelicCollectionScreen()),
                              ),
                              const SizedBox(width: 16),
                              _IconMenuButton(
                                icon: Icons.pets,
                                label: 'Bestiary',
                                onTap: () => _push(const CreatureCollectionScreen()),
                              ),
                              const SizedBox(width: 16),
                              _IconMenuButton(
                                icon: Icons.storefront,
                                label: 'Shop',
                                onTap: () => _push(const ResourceShopScreen()),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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
}

class _IconMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconMenuButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.instance.click();
        onTap();
      },
      child: Column(
        children: [
          LavaPanel(
            padding: const EdgeInsets.all(12),
            radius: 14,
            child: Icon(icon, color: AppColors.emberGold, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
