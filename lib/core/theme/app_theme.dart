import 'package:flutter/material.dart';

import 'blue_theme.dart';
import 'dark_theme.dart';
import 'light_theme.dart';
import 'purple_theme.dart';

enum AppThemeType { light, dark, blue, purple, system }

class AppTheme {
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;
  static ThemeData get blue => blueTheme;
  static ThemeData get purple => purpleTheme;

  static List<ThemeMode> get modes => [
    ThemeMode.light,
    ThemeMode.dark,
    ThemeMode.system,
  ];

  static List<AppThemeType> get themeTypes => [
    AppThemeType.light,
    AppThemeType.dark,
    AppThemeType.blue,
    AppThemeType.purple,
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
