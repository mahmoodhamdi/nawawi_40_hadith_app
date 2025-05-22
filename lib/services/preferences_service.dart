import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Keys for preferences
  static const String lastReadHadithKey = 'last_read_hadith';
  static const String lastReadTimeKey = 'last_read_time';
  static const String themeKey = 'app_theme';

  // Save the last read hadith index
  static Future<void> saveLastReadHadith(int hadithIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastReadHadithKey, hadithIndex);
    await prefs.setString(lastReadTimeKey, DateTime.now().toIso8601String());
  }

  // Get the last read hadith index
  static Future<int?> getLastReadHadith() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(lastReadHadithKey);
  }

  // Get the last read time
  static Future<DateTime?> getLastReadTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(lastReadTimeKey);
    if (timeString == null) return null;
    return DateTime.parse(timeString);
  }

  // Clear last read data
  static Future<void> clearLastReadData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(lastReadHadithKey);
    await prefs.remove(lastReadTimeKey);
  }

  // Save theme preference
  static Future<void> saveTheme(int themeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeKey, themeIndex);
  }

  // Get saved theme preference
  static Future<int?> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(themeKey);
  }
}
