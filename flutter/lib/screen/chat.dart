import 'package:flutter/material.dart';
import '../widgets/embedded_chat_view.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
    final containerShadow = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: bgColor,
          ),

          SafeArea(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: headerColor,
                    border: Border(
                      bottom: BorderSide(
                        color: headerBorder,
                        width: 1,
                      ),
                    ),
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
                          _ActionButton(
                            icon: Icons.explore,
                            label: 'Discover',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: Icons.edit,
                            label: 'New Chat',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: actionText,
                              size: 20,
                            ),
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
                      border: Border.all(
                        color: containerBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: containerShadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: EmbeddedChatView(
                      url: 'http://localhost:8501/?embed=true&theme=${isDark ? 'dark' : 'light'}',
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
              Icon(
                icon,
                size: 16,
                color: fg,
              ),
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

