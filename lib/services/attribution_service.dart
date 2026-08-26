import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps the AppsFlyer SDK to determine, once per install, whether the
/// current user is an organic (found the app themselves) or non-organic
/// (arrived via a tracked marketing campaign) install. The app itself makes
/// no gameplay decisions based on this - it only collects and exposes the
/// attribution status for analytics purposes.
class AttributionService {
  AttributionService._internal();
  static final AttributionService instance = AttributionService._internal();

  static const String _afDevKey = 'arirW5cKqWckUQzsxvHgrH';
  static const String _prefsKey = 'lava_fortune_attribution_status';

  AppsflyerSdk? _sdk;
  String? _status;

  /// 'Organic', 'Non-organic', or null while attribution hasn't resolved yet.
  String? get status => _status;
  bool get isOrganic => _status == 'Organic';
  bool get isNonOrganic => _status == 'Non-organic';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _status = prefs.getString(_prefsKey);

    final options = AppsFlyerOptions(
      afDevKey: _afDevKey,
      // Android-only integration for now; iOS app id can be added if the
      // game ships there too.
      appId: '',
      showDebug: kDebugMode,
    );
    _sdk = AppsflyerSdk(options);

    // Per AppsFlyer's docs, the conversion-data listener must be registered
    // before initSdk() is called so the very first callback isn't missed.
    _sdk!.onInstallConversionData((data) async {
      final status = data['af_status'] as String?;
      if (status == null) return;
      _status = status;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, status);
      if (status == 'Non-organic') {
        debugPrint(
          'Attribution: non-organic install (media source: ${data['media_source']}, '
          'campaign: ${data['campaign']})',
        );
      } else {
        debugPrint('Attribution: organic install');
      }
    });

    try {
      await _sdk!.initSdk(registerConversionDataCallback: true);
    } catch (e) {
      debugPrint('AppsFlyer init failed: $e');
    }
  }
}
