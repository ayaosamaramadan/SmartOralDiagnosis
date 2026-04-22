import 'package:flutter/material.dart';
import '../components/theme_toggle.dart';
import '../services/role_service.dart';
import '../models/user_role.dart';

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

              // Center: role label (shows current role if available)
              Expanded(
                child: Center(
                  child: ValueListenableBuilder<UserRole?>(
                    valueListenable: RoleService.notifier,
                    builder: (context, role, _) {
                      if (role == null) return const SizedBox.shrink();
                      final raw = role.value;
                      final label = raw.isNotEmpty
                          ? '${raw[0].toUpperCase()}${raw.substring(1)}'
                          : raw;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                ),
              ),

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
