import 'package:flutter/material.dart';
import '../data/orals.dart';
import '../theme/app_theme.dart';


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
    final appColors = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appColors.gradientStart, appColors.gradientMiddle, appColors.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 0.8],
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
                      color: Theme.of(context).cardColor,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                    color: Theme.of(context).colorScheme.surface,
                                    child: Icon(Icons.broken_image,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: colorScheme.primary,
                                child: Text(short,
                                    style: TextStyle(color: colorScheme.onPrimary)),
                              ),
                        title: Text(
                          title,
                          style: TextStyle(
                              color: colorScheme.onBackground,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          desc,
                          style: TextStyle(color: colorScheme.onBackground),
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
                                  gradient: LinearGradient(
                                    colors: [appColors.gradientStart, appColors.gradientMiddle, appColors.gradientEnd],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22),
                                    ),
                                    const SizedBox(height: 12),
                                    SingleChildScrollView(
                                      child: Text(
                                        overview,
                                        style: TextStyle(color: colorScheme.onBackground, fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Close',
                                          style: TextStyle(color: colorScheme.primary),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        backgroundColor: colorScheme.primary,
        tooltip: 'Chat',
        child: Icon(Icons.chat_bubble, color: colorScheme.onPrimary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onBackground, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 6),
              Text(
                "All Diseases",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.menu, color: colorScheme.onBackground, size: 32),
            color: Theme.of(context).cardColor,
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: _navText(context, "HOME")),
              PopupMenuItem(value: 1, child: _navText(context, "DISEASE & CONDITIONS")),
              PopupMenuItem(value: 2, child: _navText(context, "ABOUT US")),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 3,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: colorScheme.onSurface.withOpacity(0.12)),
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
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget _navText(BuildContext context, String text) {
    final color = Theme.of(context).colorScheme.onBackground;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}