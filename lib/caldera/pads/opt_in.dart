import 'package:flutter/material.dart';

import '../../app/caldera_buttons.dart';
import '../../app_assets.dart';
import '../brief/spec.dart';
import '../lines/alerts.dart';
import '../lines/vault.dart';
import 'viewport.dart';

/// One-shot push opt-in promo shown before the portal (only when
/// `keystore.shouldInvitePermission` is true — first time, or after
/// the snooze window expired).
class PermissionStage extends StatefulWidget {
  const PermissionStage({
    super.key,
    required this.keystore,
    required this.alerts,
    required this.destinationUrl,
  });

  final BeaconKeystore keystore;
  final AlertChannel alerts;
  final String destinationUrl;

  @override
  State<PermissionStage> createState() => _PermissionStageState();
}

class _PermissionStageState extends State<PermissionStage> {
  Future<void> _accept() async {
    final bool granted = await widget.alerts.askPermission();
    if (!granted) {
      await widget.keystore
          .writePermissionSnoozeUntil(_snoozeTarget());
    }
    if (mounted) _forward();
  }

  Future<void> _skip() async {
    await widget.keystore.writePermissionSnoozeUntil(_snoozeTarget());
    if (mounted) _forward();
  }

  int _snoozeTarget() =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000 +
      RelayConfig.permissionSnoozeSeconds;

  void _forward() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PortalStage(
          url: widget.destinationUrl,
          keystore: widget.keystore,
          alerts: widget.alerts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final String bg = landscape
        ? AppAssets.horizontalNotifications
        : AppAssets.verticalNotifications;

    return MediaQuery(
      data: landscape
          ? MediaQuery.of(context).copyWith(
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              viewInsets: EdgeInsets.zero,
            )
          : MediaQuery.of(context),
      child: Scaffold(
      backgroundColor: const Color(0xFF0E2238),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(bg,
              fit: BoxFit.cover, width: size.width, height: size.height),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, Color(0x88000000)],
              ),
            ),
          ),
          Positioned(
            left: size.width * 0.08,
            right: size.width * 0.08,
            bottom: size.height * (landscape ? 0.035 : 0.08),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RelayPillButton(
                  label: 'Accept',
                  compact: landscape,
                  heightFactor: landscape ? 0.93 : 1.0,
                  width: landscape ? size.width * 0.34 : size.width * 0.72,
                  onTap: _accept,
                ),
                SizedBox(height: landscape ? 12 : 16),
                RelayPillButton(
                  label: 'Skip',
                  compact: landscape,
                  heightFactor: landscape ? 0.93 : 1.0,
                  width: landscape ? size.width * 0.28 : size.width * 0.55,
                  onTap: _skip,
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
