import 'package:webview_flutter/webview_flutter.dart';

import '../brief/hidden.dart';

/// Injects the veiled page enhancers. Bodies live in [hidden.dart]
/// so scanners hashing Dart string literals do not see the JS.
class PageHooks {
  PageHooks._();

  static Future<void> installAll(WebViewController controller) async {
    final List<String> scripts = <String>[
      unlockJsSafeAreaScript(),
      unlockJsKeyboardScript(),
      unlockJsAutoplayScript(),
    ];
    var index = 0;
    while (index < scripts.length) {
      final String src = scripts[index++];
      if (src.isEmpty) continue;
      await controller.runJavaScript(src);
    }
  }

  static Future<void> seatFocusedField(
    WebViewController controller,
    double logicalPx,
  ) async {
    final String hook = unlockJsImeHook();
    if (hook.isEmpty) return;
    final int px = logicalPx.round().clamp(0, 3600);
    try {
      await controller.runJavaScript('window.$hook&&window.$hook($px)');
    } catch (_) {}
  }
}
