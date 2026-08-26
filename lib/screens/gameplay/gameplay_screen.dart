import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../models/drill.dart';
import '../../models/run_state.dart';
import '../../models/zone.dart';
import '../../services/audio_service.dart';
import '../../services/haptics_service.dart';
import '../../state/game_provider.dart';
import '../../state/run_provider.dart';
import '../../widgets/drill_art.dart';
import '../main_menu/main_menu_screen.dart';
import '../result/defeat_screen.dart';
import '../result/expedition_result_screen.dart';
import 'widgets/event_overlay.dart';
import 'widgets/gameplay_hud.dart';
import 'widgets/lane_view.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/relic_overlay.dart';

class GameplayScreen extends StatefulWidget {
  final ZoneId zoneId;
  const GameplayScreen({super.key, required this.zoneId});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  bool _resultHandled = false;

  @override
  void initState() {
    super.initState();
    // Clear any stale finished run synchronously so the very first build of
    // this screen never sees a leftover completed/defeated run from a
    // previous expedition (which would otherwise be re-processed and its
    // rewards double-applied before `start()` runs on the next frame).
    context.read<RunProvider>().reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameProvider>();
      final run = context.read<RunProvider>();
      run.start(widget.zoneId, game.effectiveStats);
      AudioService.instance.playSfx(GameAssets.sfxDrillStart);
    });
  }

  void _handleChoose(BuildContext context, int index) {
    HapticsService.instance.selection();
    AudioService.instance.playSfx(GameAssets.sfxDrillImpact);
    context.read<RunProvider>().chooseLane(index);
  }

  void _handleFinish(BuildContext context, RunState run) {
    if (_resultHandled) return;
    _resultHandled = true;
    final game = context.read<GameProvider>();
    // A run can reach its final status mid-build, and applying the result
    // notifies listeners, so the profile update has to wait for the frame to
    // finish before it can rebuild anything.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Banked before the mounted check so the haul is never lost if the
      // screen goes away between the frame and this callback.
      game.applyRunResult(run);
      if (!mounted) return;
      if (run.status == RunStatus.defeated) {
        AudioService.instance.playSfx(GameAssets.sfxFailure);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DefeatScreen(run: run)),
        );
      } else {
        AudioService.instance.playSfx(GameAssets.sfxExpeditionComplete);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ExpeditionResultScreen(run: run)),
        );
      }
    });
  }

  Future<void> _confirmExit(BuildContext context, RunProvider runProvider) async {
    final abandon = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.danger),
        ),
        title: Text('Abandon expedition?', style: AppTextStyles.sectionTitle),
        content: Text(
          'Everything mined during this run will be lost. '
          'Use EXTRACT instead to keep the loot.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep drilling'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Abandon', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (abandon != true || !mounted) return;
    runProvider.reset();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final zone = zoneById(widget.zoneId);
    final drill = drillById(context.read<GameProvider>().profile.selectedDrill);
    final runProvider = context.watch<RunProvider>();
    final run = runProvider.run;

    if (run == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (run.status == RunStatus.defeated || run.status == RunStatus.extracted) {
      _handleFinish(context, run);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (run.status == RunStatus.running) {
          runProvider.togglePause();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(zone.background, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  GameplayHud(run: run, onPause: () => runProvider.togglePause()),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (run.status == RunStatus.running)
                          SizedBox(
                            height: 190,
                            child: LaneView(
                              options: run.currentOptions,
                              onChoose: (i) => _handleChoose(context, i),
                            ),
                          ),
                        const SizedBox(height: 12),
                        DrillArt(drill: drill, height: 90),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (run.log.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        run.log.first.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: run.log.first.positive ? Colors.white70 : AppColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: run.status == RunStatus.running
                            ? () => runProvider.extract()
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.emberGold,
                          side: const BorderSide(color: AppColors.emberGold),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text('EXTRACT & KEEP LOOT'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            if (run.status == RunStatus.event && run.activeEvent != null)
              EventOverlay(
                event: run.activeEvent!,
                onResolve: (accept) => runProvider.resolveEvent(accept),
              ),
            if (run.status == RunStatus.relicFound && run.pendingRelic != null)
              RelicOverlay(
                relic: run.pendingRelic!,
                onContinue: () => runProvider.acknowledgeRelic(),
              ),
            if (run.status == RunStatus.paused)
              PauseOverlay(
                onResume: () => runProvider.togglePause(),
                onExtract: () => runProvider.extract(),
                onExit: () => _confirmExit(context, runProvider),
              ),
          ],
        ),
      ),
    );
  }
}
