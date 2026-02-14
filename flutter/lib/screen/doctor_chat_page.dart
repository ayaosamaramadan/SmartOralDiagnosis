import 'package:flutter/material.dart';

class DoctorChatPage extends StatelessWidget {
  const DoctorChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leftBg = isDark ? Colors.black : Colors.white;
    final panelBorder = isDark ? Colors.white12 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Chats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(builder: (context, constraints) {
          final twoColumn = constraints.maxWidth >= 800;

          if (!twoColumn) {
            return _buildSingleColumn(context, isDark);
          }

          return Row(
            children: [
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: leftBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: panelBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Doctors', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700])),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Icon(Icons.forum_outlined, size: 62, color: Colors.blueGrey),
                            const SizedBox(height: 18),
                            const Text('No conversations yet.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text('Start a chat with a doctor to get professional help.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600])),
                            const SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '');
                              },
                              child: const Text('Chat with doctors'),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: panelBorder),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Select a conversation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                        const SizedBox(height: 8),
                        Text('Choose a chat from the left to start messaging.', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSingleColumn(BuildContext context, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Chats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 12),
                  Icon(Icons.forum_outlined, size: 62, color: Colors.blueGrey),
                  const SizedBox(height: 12),
                  const Text('No conversations yet.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/chat'), child: const Text('Chat with doctors')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
