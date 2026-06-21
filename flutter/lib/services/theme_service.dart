import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple theme service that exposes a [ValueNotifier<ThemeMode>] and
/// persists the user's choice using `flutter_secure_storage`.
class ThemeService {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Key used to store theme choice. Possible values: 'system','light','dark'
  static const String _kThemeKey = 'app_theme_mode';

  /// Public notifier components can listen to.
  static final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.system);

  /// Initialize from persisted storage. Call once at app startup.
  static Future<void> init() async {
    try {
      final value = await _storage.read(key: _kThemeKey);
      if (value == null || value == 'system') {
        notifier.value = ThemeMode.system;
      } else if (value == 'light') {
        notifier.value = ThemeMode.light;
      } else if (value == 'dark') {
        notifier.value = ThemeMode.dark;
      } else {
        notifier.value = ThemeMode.system;
      }
    } catch (_) {
      notifier.value = ThemeMode.system;
    }
  }

  /// Persist and update theme.
  static Future<void> setThemeMode(ThemeMode mode) async {
    notifier.value = mode;
    final s = mode == ThemeMode.system ? 'system' : mode == ThemeMode.light ? 'light' : 'dark';
    try {
      await _storage.write(key: _kThemeKey, value: s);
    } catch (_) {
      // ignore
    }
  }
}
