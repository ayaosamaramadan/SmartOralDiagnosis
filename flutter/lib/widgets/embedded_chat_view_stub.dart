// Native implementation (Android/iOS/desktop) using webview_flutter.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

class EmbeddedChatView extends StatefulWidget {
  final String url;
  const EmbeddedChatView({super.key, required this.url});

  @override
  State<EmbeddedChatView> createState() => _EmbeddedChatViewState();
}

class _EmbeddedChatViewState extends State<EmbeddedChatView> {
  late final WebViewController _controller;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));

    String url = widget.url;
    // If running on Android emulator, map localhost to 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      url = url.replaceFirst('localhost', '10.0.2.2');
    }

    _controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) {
        if (mounted) setState(() => _loadFailed = false);
      },
      onWebResourceError: (err) {
        if (mounted) setState(() => _loadFailed = true);
      },
    ));
    _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      final uri = Uri.parse(widget.url);
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text('Page unavailable in embedded view'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open in browser'),
            ),
          ],
        ),
      );
    }

    return WebViewWidget(controller: _controller);
  }
}
