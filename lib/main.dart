import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/caldera_app.dart';
import 'app/system_ui.dart';
import 'caldera/dock/outcome.dart';
import 'caldera/router.dart';
import 'caldera/lines/alerts.dart';
import 'caldera/lines/install_trace.dart';
import 'caldera/lines/vault.dart';
import 'caldera/lines/ua.dart';
import 'caldera/lines/reach.dart';
import 'caldera/lines/gate_ask.dart';
import 'state/game_provider.dart';
import 'state/run_provider.dart';

// ============================================================
// main.dart — bootstrap wiring
// ============================================================
// Order of operations (do NOT reorder without reading the docs):
//   1. WidgetsFlutterBinding — required before any plugin call.
//   2. Firebase + AppCheck   — wrapped in try/catch. Failures
//      here must NEVER block startup (the coordinator will fall
//      back to the native game path).
//   3. Orientations + status-bar chrome — set once here so the
//      boot screen renders edge-to-edge on frame one.
//   4. DeviceSignature.prime — builds the forged User-Agent used
//      by both the HTTP client (BoreClient) and the WebView.
//      MUST run before any bridge or the WebView is constructed.
//   5. BeaconKeystore.prime  — reads SharedPreferences into memory
//      so the coordinator's route decision is synchronous.
//   6. Assemble the pipeline and mount CalderaApp.
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
    );
  } catch (_) {}

  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  await SystemUi.hide();

  await DeviceSignature.prime();

  final BeaconKeystore keystore = BeaconKeystore();
  await keystore.prime();

  final PulseProbe probe = PulseProbe();
  final InstallTrace pulse = InstallTrace();
  final GateAsk verdict = GateAsk(keystore);
  final AlertChannel alerts = AlertChannel(keystore);

  final RelayCoordinator coordinator = RelayCoordinator(
    keystore: keystore,
    probe: probe,
    pulse: pulse,
    verdict: verdict,
    alerts: alerts,
  );

  // Adapter check is a few milliseconds and does not DNS-probe.
  // Doing it here means the first Flutter frame is already nowifi
  // on a cold airplane-mode launch, instead of a filled loading bar.
  final bool startOffline = keystore.route != TrailMark.native &&
      !await probe.hasAdapter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => RunProvider()),
      ],
      child: CalderaApp(
        coordinator: coordinator,
        keystore: keystore,
        alerts: alerts,
        startOffline: startOffline,
      ),
    ),
  );
}
