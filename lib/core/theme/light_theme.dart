import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_styles.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Cairo',
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textPrimaryLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    error: Colors.red,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.backgroundLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF37966F),
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 1,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: const TextTheme(
    titleLarge: AppStyles.titleLargeLight,
    titleMedium: AppStyles.titleMediumLight,
    bodyMedium: AppStyles.bodyMediumLight,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppStyles.titleMediumLight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceLight,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.borderLight, width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: AppColors.surfaceLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: Colors.blue.withValues(alpha: 0.2),
    selectionHandleColor: Colors.blue.shade700,
    cursorColor: Colors.blue.shade700,
  ),
);
