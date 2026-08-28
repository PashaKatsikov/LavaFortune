import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

import '../brief/hidden.dart';
import '../brief/spec.dart';
import 'outbound.dart';

/// AppsFlyer install / deep-link / open-attribution collector.
///
/// Organic first-callback is treated as suspicious: wait
/// [RelayConfig.organicRescueDelay] then re-query GCD. A successful
/// rescue replaces the Organic payload; a failed rescue keeps it
/// (safe branch → native game).
class InstallTrace {
  InstallTrace();

  AppsflyerSdk? _sdk;
  bool _booted = false;

  Map<String, dynamic>? _install;
  Map<String, dynamic>? _deepLink;
  Map<String, dynamic>? _appOpen;

  final Completer<Map<String, dynamic>> _installDone =
      Completer<Map<String, dynamic>>();
  final Completer<void> _deepLinkDone = Completer<void>();

  Future<void> start() async {
    if (_booted) return;
    _booted = true;

    final String key = RelayConfig.attributionKey;
    if (key.isEmpty) {
      _finishInstall(const <String, dynamic>{});
      _finishDeepLink();
      return;
    }

    final AppsflyerSdk sdk = AppsflyerSdk(
      AppsFlyerOptions(
        afDevKey: key,
        appId: RelayConfig.storeNumericId,
        showDebug: kDebugMode,
        timeToWaitForATTUserAuthorization: 10,
      ),
    );
    _sdk = sdk;

    sdk.onInstallConversionData(_onInstall);
    sdk.onAppOpenAttribution(_onOpen);
    sdk.onDeepLinking(_onDeepLink);

    try {
      await sdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );
    } catch (_) {
      _finishInstall(const <String, dynamic>{});
      _finishDeepLink();
    }
  }

  Future<void> _onInstall(dynamic raw) async {
    final Map<String, dynamic> payload = _asMap(raw);
    Map<String, dynamic> chosen = payload;
    final bool organic = payload['af_status']?.toString() == 'Organic';
    if (organic) {
      await Future<void>.delayed(
        Duration(seconds: RelayConfig.organicRescueDelay),
      );
      final Map<String, dynamic>? rescued = await _queryGcd();
      if (rescued != null) chosen = rescued;
    }
    _install = chosen;
    _finishInstall(chosen);
  }

  void _onOpen(dynamic raw) {
    _appOpen = _asMap(raw);
  }

  void _onDeepLink(DeepLinkResult result) {
    final Map<String, dynamic>? click = result.deepLink?.clickEvent;
    if (click != null) {
      _deepLink = Map<String, dynamic>.from(click);
    }
    _finishDeepLink();
  }

  Future<void> awaitSignals({int? installSeconds}) async {
    final Duration installCap = Duration(
      seconds: installSeconds ?? RelayConfig.firstInstallAwaitSeconds,
    );
    final Duration linkCap = Duration(
      seconds: RelayConfig.deepLinkAwaitSeconds,
    );
    await Future.wait<void>(<Future<void>>[
      _installDone.future.timeout(installCap, onTimeout: _emptyInstall),
      _deepLinkDone.future.timeout(linkCap, onTimeout: _ignore),
    ]);
  }

  Map<String, dynamic> _emptyInstall() => <String, dynamic>{};

  void _ignore() {}

  Future<String?> deviceId() async {
    final AppsflyerSdk? sdk = _sdk;
    if (sdk == null) return null;
    try {
      return await sdk.getAppsFlyerUID();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> compose({
    required String locale,
    String? pushToken,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      ...?_install,
    };
    _deepLink?.forEach((String key, dynamic value) {
      body.putIfAbsent(key, () => value);
    });
    _appOpen?.forEach((String key, dynamic value) {
      body.putIfAbsent(key, () => value);
    });

    body['af_id'] = await deviceId() ?? '';
    body['bundle_id'] = RelayConfig.applicationId;
    body['os'] = Platform.isAndroid ? 'Android' : 'iOS';
    body['store_id'] = RelayConfig.storeId;
    body['locale'] = locale;

    if (pushToken != null && pushToken.isNotEmpty) {
      body['push_token'] = pushToken;
    }
    final String project = RelayConfig.messagingProjectId;
    if (project.isNotEmpty) {
      body['firebase_project_id'] = project;
    }

    assert(() {
      // ignore: avoid_print
      print('[CALDERA.TRACE] compose ${jsonEncode(body)}');
      return true;
    }());
    return body;
  }

  Future<Map<String, dynamic>?> _queryGcd() async {
    try {
      final String? uid = await deviceId();
      if (uid == null) return null;
      final String appRef = Platform.isIOS
          ? RelayConfig.storeNumericId
          : RelayConfig.applicationId;
      final String url = unlockGcdCallUrl(appRef, uid);
      if (url.isEmpty) return null;

      final dynamic response = await boreHttp.get(
        Uri.parse(url),
        headers: <String, String>{
          'authorization': 'Bearer ${RelayConfig.attributionKey}',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      final Object? decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map(
          (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
        );
      }
    } catch (_) {}
    return null;
  }

  void _finishInstall(Map<String, dynamic> data) {
    if (!_installDone.isCompleted) _installDone.complete(data);
  }

  void _finishDeepLink() {
    if (!_deepLinkDone.isCompleted) _deepLinkDone.complete();
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is! Map) return <String, dynamic>{};
    final dynamic inner = raw['payload'] ?? raw['data'] ?? raw;
    if (inner is! Map) return <String, dynamic>{};
    return inner.map(
      (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
    );
  }
}
