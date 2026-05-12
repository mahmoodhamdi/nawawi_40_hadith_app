import 'package:flutter/material.dart';

import 'blue_theme.dart';
import 'dark_theme.dart';
import 'light_theme.dart';
import 'purple_theme.dart';
import 'sepia_theme.dart';

// IMPORTANT — enum order is persisted as the integer index in
// SharedPreferences. Never reorder the first 5 values (light/dark/blue/
// purple/system) — that would silently change every user's saved theme
// when they upgrade. New themes must be appended at the end.
enum AppThemeType { light, dark, blue, purple, system, sepia }

class AppTheme {
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;
  static ThemeData get blue => blueTheme;
  static ThemeData get purple => purpleTheme;
  static ThemeData get sepia => sepiaTheme;

  static List<ThemeMode> get modes => [
    ThemeMode.light,
    ThemeMode.dark,
    ThemeMode.system,
  ];

  /// Order for display purposes only — Sepia is shown above System in
  /// the picker even though the enum order has it last (for backwards-
  /// compatible storage indices).
  static List<AppThemeType> get themeTypes => [
    AppThemeType.light,
    AppThemeType.dark,
    AppThemeType.blue,
    AppThemeType.purple,
    AppThemeType.sepia,
    AppThemeType.system,
  ];

  static String getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return 'Light';
      case AppThemeType.dark:
        return 'Dark';
      case AppThemeType.blue:
        return 'Blue';
      case AppThemeType.purple:
        return 'Purple';
      case AppThemeType.sepia:
        return 'Sepia';
      case AppThemeType.system:
        return 'System';
    }
  }

  static ThemeData byType(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return lightTheme;
      case AppThemeType.dark:
        return darkTheme;
      case AppThemeType.blue:
        return blueTheme;
      case AppThemeType.purple:
        return purpleTheme;
      case AppThemeType.sepia:
        return sepiaTheme;
      case AppThemeType.system:
        return lightTheme; // Default to light for system
    }
  }

  static ThemeMode themeTypeToMode(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return ThemeMode.light;
      case AppThemeType.dark:
        return ThemeMode.dark;
      case AppThemeType.system:
        return ThemeMode.system;
      default:
        return ThemeMode
            .light; // Custom themes use light mode with custom colors
    }
  }

  static ThemeData byMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      default:
        return lightTheme;
    }
  }
}
