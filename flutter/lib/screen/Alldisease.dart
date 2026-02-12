import 'package:flutter/material.dart';
import '../widgets/role_drawer.dart';
import '../data/orals.dart';
import 'disease_detail.dart';

class FixedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  const FixedButton({
    super.key,
    this.onPressed,
    this.label = 'Action',
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed ?? () {},
      label: Text(label),
      icon: Icon(icon),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }
}

class AlldiseaseScreen extends StatelessWidget {
  const AlldiseaseScreen({super.key});

  String _assetPath(String path) =>
      path.startsWith('/') ? path.substring(1) : path;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(context),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF0F050D),
                    Color.fromARGB(255, 7, 3, 21),
                    Color.fromARGB(255, 19, 22, 32),
                    Color.fromARGB(255, 42, 46, 51),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFFE3F2FD),
                    Color(0xFFBBDEFB),
                    Color(0xFF90CAF9),
                    Color(0xFF64B5F6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              _buildNavBar(context, isDark),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: orals.length,
                  itemBuilder: (context, index) {
                    final item = orals[index];
                    final title = item['title'] as String? ?? '';
                    final short = item['shortTitle'] as String? ?? '';
                    final desc = item['description'] as String? ?? '';
                    final imgList = item['img'] as List<dynamic>?;
                    final rawImg = (imgList != null && imgList.isNotEmpty)
                        ? (imgList.first as String)
                        : null;
                    final imgAsset = rawImg != null ? _assetPath(rawImg) : null;

                    return Card(
                      color: isDark
                          ? Colors.white.withAlpha(30)
                          : Colors.black.withAlpha(20),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: imgAsset != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  imgAsset,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor:
                                    isDark ? Colors.white24 : Colors.blueAccent,
                                child: Text(
                                  short,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                        title: Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          desc,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : Colors.black.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DiseaseDetailScreen(item: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        tooltip: 'Chat',
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [

          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                "All Diseases",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.blueAccent : Colors.blue.shade800,
                ),
              ),
            ],
          ),

          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : Colors.black,
                size: 32,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return const RoleDrawer();
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required BuildContext context,
    String? route,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white : Colors.black87),
      title: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
    );
  }
}