import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/core/constants.dart';
import 'package:hadith_nawawi_audio/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PreferencesService - Last Read Hadith', () {
    test('saveLastReadHadith saves valid index', () async {
      SharedPreferences.setMockInitialValues({});

      await PreferencesService.saveLastReadHadith(10);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PreferenceKeys.lastReadHadith), 10);
    });

    test('saveLastReadHadith saves timestamp', () async {
      SharedPreferences.setMockInitialValues({});

      await PreferencesService.saveLastReadHadith(5);

      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(PreferenceKeys.lastReadTime);
      expect(timeString, isNotNull);
      expect(() => DateTime.parse(timeString!), returnsNormally);
    });

    test('saveLastReadHadith throws for index below minimum', () async {
      SharedPreferences.setMockInitialValues({});

      expect(
        () => PreferencesService.saveLastReadHadith(0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('saveLastReadHadith throws for negative index', () async {
      SharedPreferences.setMockInitialValues({});

      expect(
        () => PreferencesService.saveLastReadHadith(-1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('saveLastReadHadith throws for index above maximum', () async {
      SharedPreferences.setMockInitialValues({});

      expect(
        () => PreferencesService.saveLastReadHadith(101),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('saveLastReadHadith accepts minimum valid index', () async {
      SharedPreferences.setMockInitialValues({});

      await PreferencesService.saveLastReadHadith(
        ValidationConstants.minHadithIndex,
      );

      final result = await PreferencesService.getLastReadHadith();
      expect(result, ValidationConstants.minHadithIndex);
    });

    test('saveLastReadHadith accepts maximum valid index', () async {
      SharedPreferences.setMockInitialValues({});

      await PreferencesService.saveLastReadHadith(
        ValidationConstants.maxHadithIndex,
      );

      final result = await PreferencesService.getLastReadHadith();
      expect(result, ValidationConstants.maxHadithIndex);
    });

    test('getLastReadHadith returns null when no hadith saved', () async {
      SharedPreferences.setMockInitialValues({});

      final result = await PreferencesService.getLastReadHadith();
      expect(result, isNull);
    });

    test('getLastReadHadith returns saved index', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadHadith: 25,
      });

      final result = await PreferencesService.getLastReadHadith();
      expect(result, 25);
    });

    test('getLastReadHadith clears invalid stored value below min', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadHadith: 0,
      });

      final result = await PreferencesService.getLastReadHadith();
      expect(result, isNull);

      // Verify data was cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PreferenceKeys.lastReadHadith), isNull);
    });

    test('getLastReadHadith clears invalid stored value above max', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadHadith: 999,
      });

      final result = await PreferencesService.getLastReadHadith();
      expect(result, isNull);
    });
  });

  group('PreferencesService - Last Read Time', () {
    test('getLastReadTime returns null when no time saved', () async {
      SharedPreferences.setMockInitialValues({});

      final result = await PreferencesService.getLastReadTime();
      expect(result, isNull);
    });

    test('getLastReadTime returns saved timestamp', () async {
      final savedTime = DateTime(2024, 6, 15, 10, 30);
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadTime: savedTime.toIso8601String(),
      });

      final result = await PreferencesService.getLastReadTime();
      expect(result, savedTime);
    });

    test('getLastReadTime handles corrupted date string', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadTime: 'invalid-date-string',
      });

      final result = await PreferencesService.getLastReadTime();
      expect(result, isNull);

      // Verify corrupted data was cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PreferenceKeys.lastReadTime), isNull);
    });

    test('getLastReadTime handles empty string', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadTime: '',
      });

      final result = await PreferencesService.getLastReadTime();
      expect(result, isNull);
    });

    test('getLastReadTime handles partial date string', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadTime: 'not-a-date',
      });

      final result = await PreferencesService.getLastReadTime();
      expect(result, isNull);
    });
  });

  group('PreferencesService - Clear Last Read Data', () {
    test('clearLastReadData removes all last read data', () async {
      final savedTime = DateTime(2024, 6, 15);
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadHadith: 20,
        PreferenceKeys.lastReadTime: savedTime.toIso8601String(),
      });

      await PreferencesService.clearLastReadData();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PreferenceKeys.lastReadHadith), isNull);
      expect(prefs.getString(PreferenceKeys.lastReadTime), isNull);
    });

    test('clearLastReadData works when no data exists', () async {
      SharedPreferences.setMockInitialValues({});

      // Should not throw
      await PreferencesService.clearLastReadData();

      final hadith = await PreferencesService.getLastReadHadith();
      final time = await PreferencesService.getLastReadTime();
      expect(hadith, isNull);
      expect(time, isNull);
    });

    test('clearLastReadData preserves theme preference', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadHadith: 15,
        PreferenceKeys.theme: 2,
      });

      await PreferencesService.clearLastReadData();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PreferenceKeys.lastReadHadith), isNull);
      expect(prefs.getInt(PreferenceKeys.theme), 2);
    });
  });

  group('PreferencesService - Theme', () {
    test('saveTheme saves valid theme index', () async {
      SharedPreferences.setMockInitialValues({});

      await PreferencesService.saveTheme(2);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PreferenceKeys.theme), 2);
    });

    test('saveTheme throws for negative index', () async {
      SharedPreferences.setMockInitialValues({});

      expect(
        () => PreferencesService.saveTheme(-1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('saveTheme throws for index above maximum', () async {
      SharedPreferences.setMockInitialValues({});

      expect(
        () => PreferencesService.saveTheme(11),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('saveTheme accepts minimum valid index', () async {
      SharedPreferences.setMockInitialValues({});

      await PreferencesService.saveTheme(ValidationConstants.minThemeIndex);

      final result = await PreferencesService.getSavedTheme();
      expect(result, ValidationConstants.minThemeIndex);
    });

    test('saveTheme accepts maximum valid index', () async {
      SharedPreferences.setMockInitialValues({});

      await PreferencesService.saveTheme(ValidationConstants.maxThemeIndex);

      final result = await PreferencesService.getSavedTheme();
      expect(result, ValidationConstants.maxThemeIndex);
    });

    test('getSavedTheme returns null when no theme saved', () async {
      SharedPreferences.setMockInitialValues({});

      final result = await PreferencesService.getSavedTheme();
      expect(result, isNull);
    });

    test('getSavedTheme returns saved theme', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.theme: 3,
      });

      final result = await PreferencesService.getSavedTheme();
      expect(result, 3);
    });

    test('getSavedTheme clears invalid stored value', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.theme: 999,
      });

      final result = await PreferencesService.getSavedTheme();
      expect(result, isNull);

      // Verify data was cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PreferenceKeys.theme), isNull);
    });

    test('getSavedTheme clears negative stored value', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.theme: -5,
      });

      final result = await PreferencesService.getSavedTheme();
      expect(result, isNull);
    });
  });

  group('PreferencesService - Clear All', () {
    test('clearAll removes all preferences', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadHadith: 10,
        PreferenceKeys.lastReadTime: DateTime.now().toIso8601String(),
        PreferenceKeys.theme: 2,
      });

      await PreferencesService.clearAll();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PreferenceKeys.lastReadHadith), isNull);
      expect(prefs.getString(PreferenceKeys.lastReadTime), isNull);
      expect(prefs.getInt(PreferenceKeys.theme), isNull);
    });

    test('clearAll works when no preferences exist', () async {
      SharedPreferences.setMockInitialValues({});

      // Should not throw
      await PreferencesService.clearAll();

      final hadith = await PreferencesService.getLastReadHadith();
      final time = await PreferencesService.getLastReadTime();
      final theme = await PreferencesService.getSavedTheme();
      expect(hadith, isNull);
      expect(time, isNull);
      expect(theme, isNull);
    });
  });

  group('ValidationConstants', () {
    test('hadith index range is valid', () {
      expect(ValidationConstants.minHadithIndex, greaterThan(0));
      expect(
        ValidationConstants.maxHadithIndex,
        greaterThanOrEqualTo(ValidationConstants.minHadithIndex),
      );
    });

    test('theme index range is valid', () {
      expect(ValidationConstants.minThemeIndex, greaterThanOrEqualTo(0));
      expect(
        ValidationConstants.maxThemeIndex,
        greaterThanOrEqualTo(ValidationConstants.minThemeIndex),
      );
    });
  });

  group('PreferenceKeys', () {
    test('all keys are unique', () {
      final keys = [
        PreferenceKeys.lastReadHadith,
        PreferenceKeys.lastReadTime,
        PreferenceKeys.theme,
        PreferenceKeys.hadithFontSize,
        PreferenceKeys.descriptionFontSize,
      ];

      final uniqueKeys = keys.toSet();
      expect(uniqueKeys.length, keys.length);
    });

    test('keys are not empty', () {
      expect(PreferenceKeys.lastReadHadith, isNotEmpty);
      expect(PreferenceKeys.lastReadTime, isNotEmpty);
      expect(PreferenceKeys.theme, isNotEmpty);
      expect(PreferenceKeys.hadithFontSize, isNotEmpty);
      expect(PreferenceKeys.descriptionFontSize, isNotEmpty);
    });
  });
}
