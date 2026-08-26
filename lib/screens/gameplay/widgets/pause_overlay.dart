import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../state/game_provider.dart';
import '../../../widgets/lava_button.dart';
import '../../../widgets/lava_panel.dart';
import '../../settings/settings_screen.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onExtract;
  final VoidCallback onExit;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onExtract,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      alignment: Alignment.center,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: LavaPanel(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('PAUSED', style: AppTextStyles.screenTitle),
                const SizedBox(height: 20),
                LavaButton(
                  label: 'RESUME',
                  style: LavaButtonStyle.success,
                  width: double.infinity,
                  onPressed: onResume,
                ),
                const SizedBox(height: 12),
                LavaButton(
                  label: 'EXTRACT & KEEP LOOT',
                  icon: Icons.arrow_upward,
                  fontSize: 15,
                  width: double.infinity,
                  onPressed: onExtract,
                ),
                const SizedBox(height: 12),
                LavaButton(
                  label: 'SETTINGS',
                  style: LavaButtonStyle.neutral,
                  width: double.infinity,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                LavaButton(
                  label: 'ABANDON RUN',
                  style: LavaButtonStyle.danger,
                  width: double.infinity,
                  onPressed: onExit,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => game.setSfx(!game.profile.sfxOn),
                      icon: Icon(
                        game.profile.sfxOn ? Icons.volume_up : Icons.volume_off,
                        color: AppColors.emberGold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => game.setMusic(!game.profile.musicOn),
                      icon: Icon(
                        game.profile.musicOn ? Icons.music_note : Icons.music_off,
                        color: AppColors.emberGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
