import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_styles.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Cairo',
  primaryColor: AppColors.primaryDark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.textPrimaryDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    error: Colors.red,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 1,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: const TextTheme(
    titleLarge: AppStyles.titleLargeDark,
    titleMedium: AppStyles.titleMediumDark,
    bodyMedium: AppStyles.bodyMediumDark,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppStyles.titleMediumDark,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.borderDark, width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
    ),
    filled: true,
    fillColor: AppColors.surfaceDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: Colors.blue.withValues(alpha: 0.3),
    selectionHandleColor: Colors.blue.shade300,
    cursorColor: Colors.blue.shade300,
  ),
);
