import 'package:flutter/material.dart';

/// Theme extension to hold app-specific colors (gradients and accents).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color gradientStart;
  final Color gradientMiddle;
  final Color gradientEnd;
  final Color cardBackground;
  final Color surface;
  final Color accent;

  const AppColors({
    required this.gradientStart,
    required this.gradientMiddle,
    required this.gradientEnd,
    required this.cardBackground,
    required this.surface,
    required this.accent,
  });

  @override
  AppColors copyWith({
    Color? gradientStart,
    Color? gradientMiddle,
    Color? gradientEnd,
    Color? cardBackground,
    Color? surface,
    Color? accent,
  }) {
    return AppColors(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientMiddle: gradientMiddle ?? this.gradientMiddle,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      cardBackground: cardBackground ?? this.cardBackground,
      surface: surface ?? this.surface,
      accent: accent ?? this.accent,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientMiddle: Color.lerp(gradientMiddle, other.gradientMiddle, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }

  // light / dark presets
  static const AppColors light = AppColors(
    gradientStart: Color(0xFFEEF2FF),
    gradientMiddle: Color(0xFFE6F0FF),
    gradientEnd: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFF8FAFF),
    surface: Color(0xFFFFFFFF),
    accent: Color(0xFF2563EB), // tailwind primary-600
  );

  static const AppColors dark = AppColors(
    gradientStart: Color(0xFF0F050D),
    gradientMiddle: Color.fromARGB(255, 7, 3, 21),
    gradientEnd: Color.fromARGB(255, 19, 22, 32),
    cardBackground: Color(0xFF1F2937),
    surface: Color(0xFF0B1220),
    accent: Color(0xFF3B82F6), // tailwind primary-500
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light();
    return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF2563EB),
      secondary: const Color(0xFF16A34A),
      surface: const Color(0xFFF8FAFF),
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    cardColor: const Color(0xFFF8FAFF),
    extensions: <ThemeExtension<dynamic>>[AppColors.light],
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark();
    return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF3B82F6),
      secondary: const Color(0xFF16A34A),
      surface: const Color(0xFF1F2937),
    ),
    scaffoldBackgroundColor: const Color(0xFF0B1220),
    cardColor: const Color(0xFF111827),
    extensions: <ThemeExtension<dynamic>>[AppColors.dark],
  );
}
