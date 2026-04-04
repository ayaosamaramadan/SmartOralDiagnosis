import 'package:flutter/material.dart';
import '../components/theme_toggle.dart';

/// Reusable top navigation overlay used across screens.
/// Adds a back button (left) and a theme toggle (right) placed within
/// the safe area. Use inside a `Stack`'s children list.
class AppNav extends StatelessWidget {
  final VoidCallback? onBack;
  final bool showBack;
  final bool showThemeToggle;

  const AppNav({
    super.key,
    this.onBack,
    this.showBack = true,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              if (showBack)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),

              // Theme toggle (right)
              if (showThemeToggle)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: const ThemeToggle(),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
