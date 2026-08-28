import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Status and navigation bars stay visually gone. The Flutter view
/// stays edge-to-edge so an open IME can draw the nav bar on top of
/// the WebView without shrinking it.
abstract final class SystemUi {
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  static Future<void> hide() {
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
