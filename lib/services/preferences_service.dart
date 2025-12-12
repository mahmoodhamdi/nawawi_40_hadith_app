import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing user preferences and settings
///
/// Handles persistence of:
/// - Last read hadith index and timestamp
/// - Theme preferences
class PreferencesService {
  // Keys for preferences
  static const String lastReadHadithKey = 'last_read_hadith';
  static const String lastReadTimeKey = 'last_read_time';
  static const String themeKey = 'app_theme';

  // Validation constants
  static const int minHadithIndex = 1;
  static const int maxHadithIndex = 100; // Safe upper bound
  static const int minThemeIndex = 0;
  static const int maxThemeIndex = 10; // Safe upper bound for theme indices

  /// Saves the last read hadith index with current timestamp
  ///
  /// [hadithIndex] must be a positive integer (1-based index)
  /// Throws [ArgumentError] if index is invalid
  static Future<void> saveLastReadHadith(int hadithIndex) async {
    if (hadithIndex < minHadithIndex || hadithIndex > maxHadithIndex) {
      throw ArgumentError(
        'Invalid hadith index: $hadithIndex. Must be between $minHadithIndex and $maxHadithIndex',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastReadHadithKey, hadithIndex);
    await prefs.setString(lastReadTimeKey, DateTime.now().toIso8601String());
  }

  /// Gets the last read hadith index
  ///
  /// Returns null if no hadith has been read yet or if the stored value is invalid
  static Future<int?> getLastReadHadith() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(lastReadHadithKey);

    // Validate stored value
    if (index != null &&
        (index < minHadithIndex || index > maxHadithIndex)) {
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
    final timeString = prefs.getString(lastReadTimeKey);

    if (timeString == null) return null;

    try {
      return DateTime.parse(timeString);
    } on FormatException catch (e) {
      // If the stored date is corrupted, log and clear it
      debugPrint('Invalid stored date format: $timeString. Error: $e');
      await prefs.remove(lastReadTimeKey);
      return null;
    }
  }

  /// Clears all last read data
  static Future<void> clearLastReadData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(lastReadHadithKey);
    await prefs.remove(lastReadTimeKey);
  }

  /// Saves theme preference
  ///
  /// [themeIndex] must be a valid theme index
  /// Throws [ArgumentError] if index is invalid
  static Future<void> saveTheme(int themeIndex) async {
    if (themeIndex < minThemeIndex || themeIndex > maxThemeIndex) {
      throw ArgumentError(
        'Invalid theme index: $themeIndex. Must be between $minThemeIndex and $maxThemeIndex',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeKey, themeIndex);
  }

  /// Gets the saved theme preference
  ///
  /// Returns null if no theme preference is saved or if stored value is invalid
  static Future<int?> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(themeKey);

    // Validate stored value
    if (index != null && (index < minThemeIndex || index > maxThemeIndex)) {
      debugPrint('Invalid stored theme index: $index. Clearing.');
      await prefs.remove(themeKey);
      return null;
    }

    return index;
  }

  /// Clears all preferences (useful for testing or reset functionality)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(lastReadHadithKey);
    await prefs.remove(lastReadTimeKey);
    await prefs.remove(themeKey);
  }
}
