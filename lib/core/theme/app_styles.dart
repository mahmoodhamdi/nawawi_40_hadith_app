import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  // Light theme styles
  static const TextStyle titleLargeLight = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: AppColors.textPrimaryLight,
    height: 1.3,
  );
  static const TextStyle titleMediumLight = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: AppColors.textSecondaryLight,
    height: 1.3,
  );
  static const TextStyle bodyMediumLight = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.textBodyLight,
    height: 1.5,
  );

  // Dark theme styles
  static const TextStyle titleLargeDark = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: AppColors.textPrimaryDark,
    height: 1.3,
  );
  static const TextStyle titleMediumDark = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: AppColors.textSecondaryDark,
    height: 1.3,
  );
  static const TextStyle bodyMediumDark = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.textBodyDark,
    height: 1.5,
  );
}
