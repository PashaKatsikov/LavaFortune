import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../state/game_provider.dart';
import '../../widgets/lava_panel.dart';
import '../../widgets/top_resource_bar.dart';
import '../webview/simple_webview_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  child: Text('Settings', style: AppTextStyles.screenTitle),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: LavaPanel(
                    child: Column(
                      children: [
                        _SwitchRow(
                          label: 'Music',
                          value: profile.musicOn,
                          onChanged: game.setMusic,
                        ),
                        const Divider(color: AppColors.panelBorder),
                        _SwitchRow(
                          label: 'Sound Effects',
                          value: profile.sfxOn,
                          onChanged: game.setSfx,
                        ),
                        const Divider(color: AppColors.panelBorder),
                        _SwitchRow(
                          label: 'Vibration',
                          value: profile.vibrationOn,
                          onChanged: game.setVibration,
                        ),
                        const Divider(color: AppColors.panelBorder),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Text('Language', style: AppTextStyles.body),
                              const Spacer(),
                              Text('English', style: AppTextStyles.bodyStrong.copyWith(color: AppColors.emberGold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuRow(
                          label: 'Support',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SimpleWebViewScreen(
                                title: 'Support',
                                url: GameLinks.support,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _MenuRow(
                          label: 'Privacy Policy',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SimpleWebViewScreen(
                                title: 'Privacy Policy',
                                url: GameLinks.privacyPolicy,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _MenuRow(
                          label: 'Exit Game',
                          onTap: () => _confirmExit(context),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Lava Fortune v1.0.0',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _confirmExit(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.panelBorder),
      ),
      title: Text('Exit Lava Fortune?', style: AppTextStyles.sectionTitle),
      content: Text('Your progress is already saved.', style: AppTextStyles.body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Stay')),
        TextButton(
          onPressed: () => SystemNavigator.pop(),
          child: const Text('Exit', style: TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.success,
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MenuRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panelLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.bodyStrong)),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
