import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String lastReadHadithKey = 'last_read_hadith';
  static const String lastReadTimeKey = 'last_read_time';

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
}
