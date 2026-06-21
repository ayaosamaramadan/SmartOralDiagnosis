import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _chatbotUrl = 'https://web-production-3a6039.up.railway.app';

  late final WebViewController _controller;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
  }

  WebViewController _buildController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _loadError = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _loading = false;
                _loadError = error.description.isNotEmpty
                    ? error.description
                    : 'Failed to load the chat assistant.';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_chatbotUrl));
  }

  void _reload() {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    _controller.reload();
  }

  void _retry() {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    _controller.loadRequest(Uri.parse(_chatbotUrl));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFF9FAFB);
    final headerColor = isDark ? const Color(0xFF0F1724) : Colors.white;
    final headerBorder = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final headerText = isDark ? const Color(0xFFE6EEFB) : const Color(0xFF111827);
    final actionBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
    final actionText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);
    final containerColor = isDark ? const Color(0xFF0B1220) : Colors.white;
    final containerBorder = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final containerShadow = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.04);

    final width = MediaQuery.of(context).size.width;
    final compact = width < 480;

    return Scaffold(
      body: Stack(
        children: [
          Container(width: double.infinity, height: double.infinity, color: bgColor),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: headerColor,
                    border: Border(bottom: BorderSide(color: headerBorder, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chat',
                        style: TextStyle(
                          color: headerText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          if (compact)
                            IconButton(
                              onPressed: _reload,
                              icon: Icon(Icons.edit, color: actionText, size: 20),
                              tooltip: 'New Chat',
                              style: IconButton.styleFrom(
                                backgroundColor: actionBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            )
                          else
                            _ActionButton(
                              icon: Icons.edit,
                              label: 'New Chat',
                              onPressed: _reload,
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: actionText, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: actionBg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: containerBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: containerShadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        WebViewWidget(controller: _controller),
                        if (_loading)
                          Container(
                            color: containerColor,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(strokeWidth: 2),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Loading chat...',
                                    style: TextStyle(fontSize: 13, color: actionText),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_loadError != null)
                          Container(
                            color: containerColor,
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.wifi_off, size: 36, color: actionText),
                                  const SizedBox(height: 10),
                                  Text(
                                    _loadError!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, color: actionText),
                                  ),
                                  const SizedBox(height: 14),
                                  FilledButton(
                                    onPressed: _retry,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'This assistant gives general information and does not replace professional medical care.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
    final fg = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
