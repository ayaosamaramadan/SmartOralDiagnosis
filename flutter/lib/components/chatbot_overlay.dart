import 'package:flutter/material.dart';

class ChatbotOverlay extends StatefulWidget {
  final String buttonLabel;
  final IconData buttonIcon;

  const ChatbotOverlay({
    Key? key,
    this.buttonLabel = 'Ask Chat',
    this.buttonIcon = Icons.chat_bubble_outline,
  }) : super(key: key);

  @override
  State<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<ChatbotOverlay> {
  bool open = false;

  void _toggle() => setState(() => open = !open);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // زر ثابت
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            heroTag: null, // ✅ حل مشكلة heroTag
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            onPressed: _toggle,
            child: Icon(widget.buttonIcon, size: 32),
            tooltip: widget.buttonLabel,
          ),
        ),

        // Overlay
        if (open)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // يمنع الإغلاق عند الضغط داخل
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade900.withOpacity(0.95)
                            : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 24)
                        ],
                      ),
                      child: Column(
                        children: [
                          // الهيدر
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _toggle,
                                ),
                              ],
                            ),
                          ),

                          // المحتوى
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: const [
                                SizedBox(height: 32),
                                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.blueGrey),
                                SizedBox(height: 16),
                                Text(
                                  'Chat with Medical Assistant',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Immediate and reliable medical answers — clear, concise, and trustworthy.',
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Hey! Curious about something medical? Let’s dive in',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // الإدخال
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Write your message here...',
                                      filled: true,
                                      fillColor: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.send),
                                  label: const Text('Send'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
