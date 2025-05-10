import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;

  static List<ThemeMode> get modes => [
    ThemeMode.light,
    ThemeMode.dark,
    ThemeMode.system,
  ];
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
