import 'package:flutter/material.dart';

/// Sepia / eye-care theme — warm paper-toned palette for long reading sessions.
///
/// Colors are picked from the same family used by physical Islamic manuscripts
/// (cream parchment, dark walnut text, muted bronze accents). Contrast meets
/// WCAG AA at typical reading sizes; the warm color temperature also reduces
/// blue-light strain in low-light environments.
class SepiaColors {
  SepiaColors._();

  /// Page background — warm cream, never pure white.
  static const Color background = Color(0xFFF4ECD8);

  /// Card / surface — slightly lighter for layering.
  static const Color surface = Color(0xFFFAF3E0);

  /// Primary brand accent in this theme — muted walnut brown.
  static const Color primary = Color(0xFF6F4E2C);

  /// Secondary accent — antique bronze, used for ornament + links.
  static const Color secondary = Color(0xFFB08B5A);

  /// Body text — deep coffee, not pure black, easier on the eye.
  static const Color textPrimary = Color(0xFF3A2A1E);

  /// Secondary text — desaturated.
  static const Color textSecondary = Color(0xFF6E5B47);

  /// Subtle border / divider.
  static const Color border = Color(0xFFD9CBB1);
}

final ThemeData sepiaTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Cairo',
  primaryColor: SepiaColors.primary,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: SepiaColors.primary,
    onPrimary: Color(0xFFFAF3E0),
    secondary: SepiaColors.secondary,
    onSecondary: SepiaColors.textPrimary,
    surface: SepiaColors.surface,
    onSurface: SepiaColors.textPrimary,
    error: Color(0xFFA63D2A),
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: SepiaColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: SepiaColors.primary,
    foregroundColor: Color(0xFFFAF3E0),
    centerTitle: true,
    elevation: 1,
    iconTheme: IconThemeData(color: Color(0xFFFAF3E0)),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: SepiaColors.textPrimary,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
    ),
    titleMedium: TextStyle(
      color: SepiaColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
    ),
    bodyMedium: TextStyle(
      color: SepiaColors.textPrimary,
      fontSize: 16,
      height: 1.6,
      fontFamily: 'Cairo',
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: SepiaColors.primary,
      foregroundColor: const Color(0xFFFAF3E0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  cardTheme: CardThemeData(
    color: SepiaColors.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: SepiaColors.border, width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: SepiaColors.border, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: SepiaColors.border, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: SepiaColors.primary, width: 2),
    ),
    filled: true,
    fillColor: SepiaColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: SepiaColors.secondary.withValues(alpha: 0.3),
    selectionHandleColor: SepiaColors.primary,
    cursorColor: SepiaColors.primary,
  ),
);
