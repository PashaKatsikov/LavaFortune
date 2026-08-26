import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/assets.dart';
import '../../services/audio_service.dart';
import '../../state/game_provider.dart';
import '../main_menu/main_menu_screen.dart';

/// Splash / loading screen. Supports both portrait and landscape (as
/// requested) since it may briefly be shown before orientation is locked.
/// All other screens in the game are portrait-only.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  double _progress = 0;
  String _statusText = 'Igniting the drill...';
  late final AnimationController _pulseController;

  static const List<String> _statusSteps = [
    'Igniting the drill...',
    'Charting volcanic tunnels...',
    'Calibrating heat sensors...',
    'Polishing ancient relics...',
    'Waking volcanic creatures...',
    'Ready to descend.',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _startLoading();
  }

  Future<void> _startLoading() async {
    final stopwatch = Stopwatch()..start();

    final gameFuture = context.read<GameProvider>().load();
    final audioFuture = AudioService.instance.init();

    // Drive a smooth, slightly irregular progress bar while real work happens.
    for (int i = 0; i < _statusSteps.length; i++) {
      if (!mounted) return;
      setState(() {
        _statusText = _statusSteps[i];
        _progress = (i + 1) / _statusSteps.length;
      });
      await Future.delayed(const Duration(milliseconds: 420));
    }

    await Future.wait([gameFuture, audioFuture]);

    await _precacheAssets();

    final minDuration = const Duration(milliseconds: 2600);
    final elapsed = stopwatch.elapsed;
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }

    if (!mounted) return;

    // Lock to portrait for the rest of the game experience.
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
    );
  }

  Future<void> _precacheAssets() async {
    if (!mounted) return;
    final toPrecache = [
      GameAssets.gameLogo,
      GameAssets.bgUpperTunnels,
      GameAssets.drillMain,
    ];
    for (final asset in toPrecache) {
      try {
        await precacheImage(AssetImage(asset), context);
      } catch (_) {
        // Ignore precache failures - images will still lazy-load.
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    final backgroundAsset =
        orientation == Orientation.portrait ? GameAssets.verticalLoading : GameAssets.horizontalLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(backgroundAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.4, 0.8, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.03);
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Icon(
                      Icons.local_fire_department,
                      color: AppColors.lavaOrange.withValues(alpha: 0.9),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 12,
                      child: Stack(
                        children: [
                          Container(color: Colors.black45),
                          AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 350),
                            widthFactor: _progress,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppColors.lavaButtonGradient,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusText,
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.caption.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
