import 'package:flutter/material.dart';

import '../boot/boot_screen.dart';
import '../core/app_colors.dart';
import '../caldera/brief/spec.dart';
import '../caldera/router.dart';
import '../caldera/pads/no_link.dart';
import '../caldera/lines/alerts.dart';
import '../caldera/lines/vault.dart';
import 'system_ui.dart';

/// Root widget. Owns the long-lived infrastructure (keystore,
/// alerts, coordinator) and hands them to the boot screen.
class CalderaApp extends StatefulWidget {
  const CalderaApp({
    super.key,
    required this.coordinator,
    required this.keystore,
    required this.alerts,
    this.startOffline = false,
  });

  final RelayCoordinator coordinator;
  final BeaconKeystore keystore;
  final AlertChannel alerts;
  final bool startOffline;

  @override
  State<CalderaApp> createState() => _CalderaAppState();
}

class _CalderaAppState extends State<CalderaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemUi.hide();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) SystemUi.hide();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: RelayConfig.displayName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.lavaOrange,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      builder: (BuildContext context, Widget? child) =>
          MediaQuery.withClampedTextScaling(
        minScaleFactor: 1.0,
        maxScaleFactor: 1.15,
        child: child ?? const SizedBox.shrink(),
      ),
      home: widget.startOffline
          ? OfflineStage(
              onRetryBuild: (_) => BootScreen(
                coordinator: widget.coordinator,
                keystore: widget.keystore,
                alerts: widget.alerts,
              ),
            )
          : BootScreen(
              coordinator: widget.coordinator,
              keystore: widget.keystore,
              alerts: widget.alerts,
            ),
    );
  }
}
