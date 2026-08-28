import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app/caldera_theme.dart';
import '../app_assets.dart';
import '../core/app_colors.dart';
import '../core/assets.dart';
import '../caldera/dock/outcome.dart';
import '../caldera/router.dart';
import '../caldera/pads/no_link.dart';
import '../caldera/pads/opt_in.dart';
import '../caldera/pads/viewport.dart';
import '../caldera/lines/alerts.dart';
import '../caldera/lines/vault.dart';
import '../screens/main_menu/main_menu_screen.dart';
import '../services/audio_service.dart';
import '../state/game_provider.dart';

// ============================================================
// BOOT SCREEN — the ONLY startup surface
// ============================================================
// One responsibility: show the loading art + progress bar while
// [RelayCoordinator.decide] resolves, then destructure the sealed
// `Docking` type and push exactly one route. This file contains
// zero routing logic beyond `switch (landing)`; everything else
// lives in `caldera/`.
// ============================================================

class BootScreen extends StatefulWidget {
  const BootScreen({
    super.key,
    required this.coordinator,
    required this.keystore,
    required this.alerts,
  });

  final RelayCoordinator coordinator;
  final BeaconKeystore keystore;
  final AlertChannel alerts;

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _dotsPeriod = Duration(milliseconds: 1200);

  double _progress = 0.04;
  bool _landed = false;
  bool _offlineNow = false;
  late final AnimationController _dots;

  @override
  void initState() {
    super.initState();
    _dots = AnimationController(vsync: this, duration: _dotsPeriod)..repeat();
    _start();
  }

  @override
  void dispose() {
    _dots.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    // No adapter → nowifi on the first frame, before the loading art
    // or a filled progress bar has had a chance to paint.
    if (widget.keystore.route != TrailMark.native) {
      final bool adapter = await widget.coordinator.probe.hasAdapter();
      if (!mounted) return;
      if (!adapter) {
        _landed = true;
        setState(() => _offlineNow = true);
        return;
      }
    }
    await _drive();
  }

  Future<void> _drive() async {
    final Docking outcome =
        await widget.coordinator.decide(onProgress: _liftProgress);
    if (!mounted || _landed) return;

    if (outcome is GapDock) {
      _landed = true;
      setState(() => _offlineNow = true);
      return;
    }

    _landed = true;
    await _settle();
    if (!mounted) return;

    final Widget next = switch (outcome) {
      NativeDock() => await _buildNativeDock(),
      ViewDock(url: final String url, coldTap: final bool coldTap) =>
        _buildViewDock(url: url, skipPermission: coldTap),
      GapDock() => _buildGapDock(),
    };
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => next),
    );
  }

  Future<Widget> _buildNativeDock() async {
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    if (!mounted) return const SizedBox.shrink();
    await context.read<GameProvider>().load();
    await AudioService.instance.init();
    await _warmGameArt();
    return const MainMenuScreen();
  }

  Widget _buildViewDock({
    required String url,
    required bool skipPermission,
  }) {
    if (!skipPermission && widget.keystore.shouldInvitePermission) {
      return PermissionStage(
        keystore: widget.keystore,
        alerts: widget.alerts,
        destinationUrl: url,
      );
    }
    return PortalStage(
      url: url,
      keystore: widget.keystore,
      alerts: widget.alerts,
    );
  }

  Widget _buildGapDock() {
    return OfflineStage(
      onRetryBuild: (_) => BootScreen(
        coordinator: widget.coordinator,
        keystore: widget.keystore,
        alerts: widget.alerts,
      ),
    );
  }

  Future<void> _warmGameArt() async {
    const List<String> paths = <String>[
      GameAssets.gameLogo,
      GameAssets.bgUpperTunnels,
      GameAssets.drillMain,
    ];
    for (final String path in paths) {
      if (!mounted) return;
      try {
        await precacheImage(AssetImage(path), context);
      } catch (_) {}
    }
  }

  void _liftProgress(double value) {
    if (mounted) setState(() => _progress = value);
  }

  Future<void> _settle() =>
      Future<void>.delayed(const Duration(milliseconds: 320));

  @override
  Widget build(BuildContext context) {
    if (_offlineNow) return _buildGapDock();

    final bool landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final String bg = landscape
        ? AppAssets.horizontalLoading
        : AppAssets.verticalLoading;

    return MediaQuery(
      data: landscape
          ? MediaQuery.of(context).copyWith(
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              viewInsets: EdgeInsets.zero,
            )
          : MediaQuery.of(context),
      child: Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(bg, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, Color(0x88000000)],
              ),
            ),
          ),
          SafeArea(
            top: !landscape,
            bottom: !landscape,
            left: !landscape,
            right: !landscape,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(34, 0, 34, 46),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _dots,
                    builder: (BuildContext context, _) {
                      final int n = (_dots.value * 4).floor() % 4;
                      return Text(
                        'Loading${'.' * n}',
                        style: RelayTheme.titleStyle(size: 24),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _ProgressTrack(value: _progress),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        return Container(
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0x55000000),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              width: c.maxWidth * value.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: AppColors.lavaButtonGradient,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }
}
