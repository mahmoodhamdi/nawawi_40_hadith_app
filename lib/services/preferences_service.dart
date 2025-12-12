import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Service responsible for managing user preferences and settings
///
/// Handles persistence of:
/// - Last read hadith index and timestamp
/// - Theme preferences
class PreferencesService {

  /// Saves the last read hadith index with current timestamp
  ///
  /// [hadithIndex] must be a positive integer (1-based index)
  /// Throws [ArgumentError] if index is invalid
  static Future<void> saveLastReadHadith(int hadithIndex) async {
    if (hadithIndex < ValidationConstants.minHadithIndex ||
        hadithIndex > ValidationConstants.maxHadithIndex) {
      throw ArgumentError(
        'Invalid hadith index: $hadithIndex. Must be between '
        '${ValidationConstants.minHadithIndex} and ${ValidationConstants.maxHadithIndex}',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PreferenceKeys.lastReadHadith, hadithIndex);
    await prefs.setString(
      PreferenceKeys.lastReadTime,
      DateTime.now().toIso8601String(),
    );
  }

  /// Gets the last read hadith index
  ///
  /// Returns null if no hadith has been read yet or if the stored value is invalid
  static Future<int?> getLastReadHadith() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(PreferenceKeys.lastReadHadith);

    // Validate stored value
    if (index != null &&
        (index < ValidationConstants.minHadithIndex ||
            index > ValidationConstants.maxHadithIndex)) {
      debugPrint('Invalid stored hadith index: $index. Clearing data.');
      await clearLastReadData();
      return null;
    }

    return index;
  }

  /// Gets the last read timestamp
  ///
  /// Returns null if:
  /// - No timestamp is stored
  /// - Stored timestamp is corrupted or invalid
  static Future<DateTime?> getLastReadTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(PreferenceKeys.lastReadTime);

    if (timeString == null) return null;

    try {
      return DateTime.parse(timeString);
    } on FormatException catch (e) {
      // If the stored date is corrupted, log and clear it
      debugPrint('Invalid stored date format: $timeString. Error: $e');
      await prefs.remove(PreferenceKeys.lastReadTime);
      return null;
    }
  }

  /// Clears all last read data
  static Future<void> clearLastReadData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferenceKeys.lastReadHadith);
    await prefs.remove(PreferenceKeys.lastReadTime);
  }

  /// Saves theme preference
  ///
  /// [themeIndex] must be a valid theme index
  /// Throws [ArgumentError] if index is invalid
  static Future<void> saveTheme(int themeIndex) async {
    if (themeIndex < ValidationConstants.minThemeIndex ||
        themeIndex > ValidationConstants.maxThemeIndex) {
      throw ArgumentError(
        'Invalid theme index: $themeIndex. Must be between '
        '${ValidationConstants.minThemeIndex} and ${ValidationConstants.maxThemeIndex}',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PreferenceKeys.theme, themeIndex);
  }

  /// Gets the saved theme preference
  ///
  /// Returns null if no theme preference is saved or if stored value is invalid
  static Future<int?> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(PreferenceKeys.theme);

    // Validate stored value
    if (index != null &&
        (index < ValidationConstants.minThemeIndex ||
            index > ValidationConstants.maxThemeIndex)) {
      debugPrint('Invalid stored theme index: $index. Clearing.');
      await prefs.remove(PreferenceKeys.theme);
      return null;
    }

    return index;
  }

  /// Clears all preferences (useful for testing or reset functionality)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferenceKeys.lastReadHadith);
    await prefs.remove(PreferenceKeys.lastReadTime);
    await prefs.remove(PreferenceKeys.theme);
  }
}
