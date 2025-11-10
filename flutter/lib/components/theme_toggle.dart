import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// A small toggle button that mirrors the Next.js ThemeToggle behavior:
/// - shows the current effective theme icon
/// - toggles between light/dark and persists choice
/// - waits for ThemeService notifier to be initialized (mounted-like guard)
class ThemeToggle extends StatefulWidget {
  const ThemeToggle({Key? key}) : super(key: key);

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (mounted) setState(() => _ready = true);
    });
  }

  void _toggle() {
    final current = ThemeService.notifier.value;
    if (current == ThemeMode.dark) {
      ThemeService.setThemeMode(ThemeMode.light);
    } else if (current == ThemeMode.light) {
      ThemeService.setThemeMode(ThemeMode.dark);
    } else {
    
      ThemeService.setThemeMode(ThemeMode.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.notifier,
      builder: (context, mode, _) {
      
        final brightness = mode == ThemeMode.system
            ? MediaQuery.of(context).platformBrightness
            : (mode == ThemeMode.dark ? Brightness.dark : Brightness.light);

        final isDark = brightness == Brightness.dark;

        return IconButton(
          tooltip: 'Toggle theme',
          onPressed: _toggle,
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF7DD3FC), Color(0xFF818CF8)],
              ),
            ),
            child: Align(
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    isDark ? Icons.wb_sunny : Icons.nightlight_round,
                    size: 14,
                    color: Colors.indigo,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
