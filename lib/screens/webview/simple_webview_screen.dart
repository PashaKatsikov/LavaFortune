import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';

class SimpleWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const SimpleWebViewScreen({super.key, required this.title, required this.url});

  @override
  State<SimpleWebViewScreen> createState() => _SimpleWebViewScreenState();
}

class _SimpleWebViewScreenState extends State<SimpleWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Pages served without their own styling default to dark body text, so
      // the view must stay light to keep that text readable.
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _error = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _error = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _retry() {
    setState(() {
      _error = false;
      _loading = true;
    });
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        title: Text(widget.title, style: AppTextStyles.sectionTitle),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _controller)),
          if (_loading && !_error)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.white,
                child: Center(child: CircularProgressIndicator(color: AppColors.lavaOrange)),
              ),
            ),
          if (_error)
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.backgroundDeep,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off, color: AppColors.textMuted, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Could not load the page. Check your connection and try again.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _retry,
                          child: const Text('Retry', style: TextStyle(color: AppColors.emberGold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
