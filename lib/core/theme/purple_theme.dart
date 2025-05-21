import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_styles.dart';

final ThemeData purpleTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Cairo',
  primaryColor: AppColors.purpleThemePrimary,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.purpleThemePrimary,
    onPrimary: Colors.white,
    secondary: AppColors.purpleThemeSecondary,
    onSecondary: AppColors.textPrimaryLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    error: Colors.red,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.backgroundLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.purpleThemePrimary,
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
      backgroundColor: AppColors.purpleThemePrimary,
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
  dividerTheme: const DividerThemeData(
    color: AppColors.borderLight,
    thickness: 1,
    space: 1,
  ),
  iconTheme: const IconThemeData(color: AppColors.purpleThemePrimary, size: 24),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.purpleThemePrimary,
        width: 2,
      ),
    ),
  ),
);
