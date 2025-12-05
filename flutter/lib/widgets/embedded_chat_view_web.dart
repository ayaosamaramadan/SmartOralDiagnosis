// Web implementation: renders an iframe via HtmlElementView.
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmbeddedChatView extends StatelessWidget {
  final String url;
  const EmbeddedChatView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final viewId = 'embedded-chat-iframe-${url.hashCode}';

    // Register a view factory for this iframe id. If already registered, this is a no-op.
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true
        ..setAttribute('sandbox', 'allow-same-origin allow-scripts allow-forms allow-popups');
      return iframe;
    });

    return Stack(
      children: [
        HtmlElementView(viewType: viewId),
        Positioned(
          right: 8,
          top: 8,
          child: IconButton(
            icon: const Icon(Icons.open_in_browser, color: Color(0xFF0B72E3)),
            onPressed: () async {
              final uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            tooltip: 'Open in browser',
          ),
        ),
      ],
    );
  }
}
