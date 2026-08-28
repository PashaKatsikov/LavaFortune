import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../app/system_ui.dart';
import '../brief/spec.dart';
import '../lines/alerts.dart';
import '../lines/vault.dart';
import '../lines/ua.dart';
import '../lines/reach.dart';
import '../lines/page_hooks.dart';
import 'no_link.dart';

// ============================================================
// PORTAL STAGE — the WebView shell (gray content)
// ============================================================
// Hosts the destination URL with:
//   • forged device UA (identical to the HTTP client's UA)
//   • both orientations, immersive system UI
//   • display-cutout padding from the native insets bridge — the
//     notch is kept clear in both orientations while the navigation
//     bar is NOT, so it can overlay the page without resizing it
//   • keyboard coverage pushed into the page as a JS enhancer call
//   • external-scheme hand-off (tel:, mailto:, intent://)
//   • redirect-loop recovery (main-frame -1007 / -9 with a
//     bounded retry)
//   • live connectivity guard (debounced)
//   • warm push URL delivery via [AlertChannel.onIncomingUrl]
//   • native file chooser via MethodChannel (no file_picker dep)
//   • JS behaviours composed by `PageHooks.installAll`
//
// NOTE: There is NO client-side classification of partner pages.
// Any funnel needed by the business must live server
// side; the client is a dumb shell.
// ============================================================

class PortalStage extends StatefulWidget {
  const PortalStage({
    super.key,
    required this.url,
    required this.keystore,
    required this.alerts,
  });

  final String url;
  final BeaconKeystore keystore;
  final AlertChannel alerts;

  @override
  State<PortalStage> createState() => _PortalStageState();
}

class _PortalStageState extends State<PortalStage>
    with WidgetsBindingObserver {
  late final WebViewController _web;
  bool _spinner = true;
  bool _offlineShown = false;
  String? _lastMainFrame;
  int _retryCounter = 0;
  Timer? _dropDebounce;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  // Camera-cutout gutter from the Android displayCutout inset.
  // Never derived from MediaQuery.viewPadding: in landscape that
  // also carries the navigation bar, which must overlay the page.
  //
  // Kept per orientation. The native value arrives over a channel, so
  // it lands a frame or two after the rotation — applying it then
  // resizes the WebView a second time and the page visibly re-flows
  // in steps. Cached, the gutter for an already-seen orientation is
  // picked during build, in the same frame as the new size.
  EdgeInsets _uprightCut = EdgeInsets.zero;
  EdgeInsets _sidewaysCut = EdgeInsets.zero;
  double _imeLogical = 0;

  // [FORGE] Rotate the MethodChannel name per project. Keep in
  // sync with MainActivity.kt → `channelName`.
  static const MethodChannel _uploadChannel = MethodChannel('magmahole/upload');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemUi.hide();
    _buildController();
    _uploadChannel.setMethodCallHandler(_onChromePulse);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pullPane());

    widget.alerts.onIncomingUrl = (String url) {
      if (mounted) _web.loadRequest(Uri.parse(url));
    };

    // Debounce connectivity drops — a VPN reconnect or a brief cell
    // switch produces a burst of `none` events that must not fire
    // the offline stage. Only sustained drops route out.
    _connSub = PulseProbe().statusStream.listen((List<ConnectivityResult> r) {
      final bool allNone =
          r.isNotEmpty && r.every((ConnectivityResult e) => e == ConnectivityResult.none);
      if (!allNone) {
        _dropDebounce?.cancel();
        return;
      }
      _dropDebounce?.cancel();
      _dropDebounce = Timer(
        Duration(milliseconds: RelayConfig.reachDropDebounceMs),
        _showOffline,
      );
    });
  }

  void _enterImmersive() {
    SystemUi.hide();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _enterImmersive();
  }

  @override
  void didChangeMetrics() => _pullPane();

  Future<dynamic> _onChromePulse(MethodCall call) async {
    if (call.method != 'chromePulse') return;
    final Object? raw = call.arguments;
    if (raw is Map) await _applyPane(Map<dynamic, dynamic>.from(raw));
  }

  Future<void> _applyPane(Map<dynamic, dynamic> pane) async {
    if (!mounted) return;
    final EdgeInsets notch = EdgeInsets.only(
      left: (pane['cutLeft'] as num?)?.toDouble() ?? 0,
      top: (pane['cutTop'] as num?)?.toDouble() ?? 0,
      right: (pane['cutRight'] as num?)?.toDouble() ?? 0,
    );
    // Which slot the reading belongs to is read off the notch itself,
    // not off MediaQuery: metrics can arrive mid-rotation, when the
    // two disagree.
    final bool sideways = notch.left > 0 || notch.right > 0;
    if (sideways) {
      if (notch != _sidewaysCut) setState(() => _sidewaysCut = notch);
    } else if (notch != _uprightCut) {
      setState(() => _uprightCut = notch);
    }

    final double ime = (pane['ime'] as num?)?.toDouble() ?? 0;
    if ((ime - _imeLogical).abs() < 1) return;
    _imeLogical = ime;
    await PageHooks.seatFocusedField(_web, ime);
  }

  /// Cutout gutter + live IME height from Android; the page, not the
  /// WebView widget, moves the focused field into the remaining band.
  Future<void> _pullPane() async {
    if (!mounted) return;
    try {
      final Object? native =
          await _uploadChannel.invokeMethod<Object>('readPane');
      if (native is Map) {
        await _applyPane(Map<dynamic, dynamic>.from(native));
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    final view = View.of(context);
    await PageHooks.seatFocusedField(
      _web,
      view.viewInsets.bottom / view.devicePixelRatio,
    );
  }

  void _buildController() {
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(DeviceSignature.userAgent)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _spinner = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _spinner = false);
          _retryCounter = 0;
          PageHooks.installAll(_web).whenComplete(_pullPane);
        },
        onWebResourceError: _onError,
        onNavigationRequest: _onNavigate,
      ));

    _configureAndroid();
    _web.loadRequest(Uri.parse(widget.url));
  }

  void _onError(WebResourceError err) {
    if (err.isForMainFrame != true) return;

    final String desc = err.description.toLowerCase();
    final bool isLoop = desc.contains('too_many_redirects') ||
        desc.contains('too many redirects') ||
        err.errorCode == -1007 ||
        err.errorCode == -9;

    if (isLoop &&
        _lastMainFrame != null &&
        _retryCounter < RelayConfig.redirectLoopRetries) {
      _retryCounter++;
      _web.loadRequest(Uri.parse(_lastMainFrame!));
      return;
    }

    // Cover the WebView's native error page immediately so the
    // Android chrome robot never leaks visually.
    if (mounted) setState(() => _spinner = true);

    final bool isConnectivity = desc.contains('name_not_resolved') ||
        desc.contains('address_unreachable') ||
        desc.contains('internet_disconnected') ||
        desc.contains('network_changed') ||
        err.errorCode == -105 ||
        err.errorCode == -106 ||
        err.errorCode == -21 ||
        err.errorCode == -2 ||
        err.errorCode == -6;

    if (isConnectivity) {
      _showOffline();
    } else {
      _guardOffline();
    }
  }

  NavigationDecision _onNavigate(NavigationRequest req) {
    final Uri? uri = Uri.tryParse(req.url);
    if (uri == null) return NavigationDecision.prevent;
    const Set<String> inApp = <String>{
      'http',
      'https',
      'about',
      'data',
      'blob',
    };
    if (inApp.contains(uri.scheme)) {
      if (req.isMainFrame) _lastMainFrame = req.url;
      return NavigationDecision.navigate;
    }
    _openExternally(uri);
    return NavigationDecision.prevent;
  }

  void _configureAndroid() {
    if (!Platform.isAndroid) return;
    if (_web.platform is! AndroidWebViewController) return;
    final AndroidWebViewController controller =
        _web.platform as AndroidWebViewController;

    controller.setMediaPlaybackRequiresUserGesture(false);
    controller.setOnPlatformPermissionRequest(
      (PlatformWebViewPermissionRequest r) => r.grant(),
    );
    controller.setOnShowFileSelector(_pickFiles);

    final AndroidWebViewCookieManager cookies = AndroidWebViewCookieManager(
      AndroidWebViewCookieManagerCreationParams
          .fromPlatformWebViewCookieManagerCreationParams(
        const PlatformWebViewCookieManagerCreationParams(),
      ),
    );
    cookies.setAcceptThirdPartyCookies(controller, true);
  }

  Future<List<String>> _pickFiles(FileSelectorParams params) async {
    try {
      final List<Object?>? picked = await _uploadChannel
          .invokeMethod<List<Object?>>('pick', <String, Object>{
        'multiple': params.mode == FileSelectorMode.openMultiple,
        'mimeTypes': params.acceptTypes
            .where((String t) => t.trim().isNotEmpty)
            .toList(),
      });
      if (picked == null) return const <String>[];
      return picked.whereType<String>().toList();
    } catch (_) {
      return const <String>[];
    }
  }

  Future<void> _openExternally(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _guardOffline() async {
    if (_offlineShown) return;
    final bool online = await PulseProbe().canDialOut();
    if (online) return;
    _showOffline();
  }

  void _showOffline() {
    if (_offlineShown || !mounted) return;
    _offlineShown = true;
    final String current = _lastMainFrame ?? widget.url;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OfflineStage(
          onRetryBuild: (_) => PortalStage(
            url: current,
            keystore: widget.keystore,
            alerts: widget.alerts,
          ),
        ),
      ),
    );
  }

  Future<void> _stepBack() async {
    if (await _web.canGoBack()) await _web.goBack();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uploadChannel.setMethodCallHandler(null);
    _dropDebounce?.cancel();
    _connSub?.cancel();
    widget.alerts.onIncomingUrl = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final EdgeInsets gutter = landscape ? _sidewaysCut : _uprightCut;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (!didPop) await _stepBack();
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          viewInsets: EdgeInsets.zero,
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Padding(
                padding: gutter,
                child: WebViewWidget(controller: _web),
              ),
              if (_spinner && !landscape)
                const ColoredBox(
                  color: Color(0x80000000),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFFF6A1A)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
