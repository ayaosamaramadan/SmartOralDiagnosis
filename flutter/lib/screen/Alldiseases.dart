import 'package:flutter/material.dart';
import '../data/orals.dart';


class FixedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  const FixedButton({super.key, this.onPressed, this.label = 'Action', this.icon = Icons.add});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed ?? () {},
      label: Text(label),
      icon: Icon(icon),
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }
}

class AlldiseasesScreen extends StatelessWidget {
  const AlldiseasesScreen({super.key});

  String _assetPath(String path) =>
      path.startsWith('/') ? path.substring(1) : path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F050D),
              Color.fromARGB(255, 7, 3, 21),
              Color.fromARGB(255, 19, 22, 32),
              Color.fromARGB(255, 42, 46, 51),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildNavBar(context),
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
                      color: Colors.white.withAlpha((0.07 * 255).round()),
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
                                  errorBuilder: (ctx, err, st) => Container(
                                    width: 64,
                                    height: 64,
                                    color: Colors.grey.shade800,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.white54),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                child: Text(short,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                        title: Text(
                          title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          desc,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          final overview = item['overview'] as String? ?? '';
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              contentPadding: const EdgeInsets.all(16),
                              backgroundColor: Colors.transparent,
                              content: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0F050D),
                                      Color.fromARGB(255, 7, 3, 21),
                                      Color.fromARGB(255, 19, 22, 32),
                                      Color.fromARGB(255, 42, 46, 51),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: [0.0, 0.5, 0.8, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22),
                                    ),
                                    const SizedBox(height: 12),
                                    SingleChildScrollView(
                                      child: Text(
                                        overview,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(
                                              color: Colors.blueAccent),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
      floatingActionButton: const FixedButton(
        label: 'Help',
        icon: Icons.help_outline,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 6),
              const Text(
                "All Diseases",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.menu, color: Colors.white, size: 32),
            color: Colors.black87,
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: _navText("HOME")),
              PopupMenuItem(value: 1, child: _navText("DISEASE & CONDITIONS")),
              PopupMenuItem(value: 2, child: _navText("ABOUT US")),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 3,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("CONTACT US"),
                ),
              ),
              PopupMenuItem(
                value: 4,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text("LOGIN"),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.pushNamed(context, '/');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/Alldiseasea');
                  break;
                case 2:
                  // TODO: Add About Us page navigation
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _navText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
