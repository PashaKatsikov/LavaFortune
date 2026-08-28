// ============================================================
// INLINE BEACON — cold-boot deep-link consumption
// ============================================================
// A cold-boot push tap on Android delivers the URL through the
// launch intent, which Firebase Messaging surfaces via
// `getInitialMessage()`. This class is the one-shot reader the
// coordinator calls before it routes.
//
// It reads the intent itself rather than waiting for
// `AlertChannel.boot()`: boot fetches the FCM token, which can
// stall for seconds on a cold network, and the tapped URL would
// then arrive after the routing decision had already been made.
// ============================================================

import '../brief/spec.dart';
import 'alerts.dart';

class InlineBeacon {
  InlineBeacon._();

  /// Returns the URL carried by the push notification that launched
  /// the app, or `null` when this is an ordinary launch.
  static Future<String?> consume(AlertChannel alerts) => alerts.coldTapUrl(
        within: const Duration(seconds: RelayConfig.pushLaunchAwaitSeconds),
      );
}
