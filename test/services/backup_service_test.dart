import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/services/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BackupService — export', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('snapshot has required top-level fields', () async {
      final snap = await BackupService.buildSnapshot();
      expect(snap['app'], 'nawawi_40_hadith_app');
      expect(snap['schema'], BackupService.schemaVersion);
      expect(snap['created_at'], isA<String>());
      expect(snap['entries'], isA<Map>());
    });

    test('exports only allowed keys and wraps with type tags', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme': 2,
        'reminder_enabled': true,
        'favorite_hadiths': ['1', '5', '10'],
        // disallowed key — should be ignored
        'some_random_other_app_key': 'leak',
      });

      final snap = await BackupService.buildSnapshot();
      final entries = snap['entries'] as Map<String, dynamic>;

      expect(entries['app_theme'], {'t': 'int', 'v': 2});
      expect(entries['reminder_enabled'], {'t': 'bool', 'v': true});
      expect(entries['favorite_hadiths'], {
        't': 'stringList',
        'v': ['1', '5', '10'],
      });
      expect(entries.containsKey('some_random_other_app_key'), isFalse);
    });

    test('exportToString produces valid JSON', () async {
      SharedPreferences.setMockInitialValues({'app_theme': 1});
      final str = await BackupService.exportToString();
      final reparsed = json.decode(str);
      expect(reparsed, isA<Map>());
    });
  });

  group('BackupService — import', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Map<String, dynamic> makeBackup(
      Map<String, dynamic> entries, {
      int schema = BackupService.schemaVersion,
      String app = 'nawawi_40_hadith_app',
    }) {
      return {
        'app': app,
        'schema': schema,
        'created_at': '2026-05-12T00:00:00Z',
        'entries': entries,
      };
    }

    test('restores valid backup and reports count', () async {
      final backup = makeBackup({
        'app_theme': {'t': 'int', 'v': 3},
        'reminder_enabled': {'t': 'bool', 'v': true},
        'favorite_hadiths': {
          't': 'stringList',
          'v': ['7', '14'],
        },
      });

      final count = await BackupService.importFromString(json.encode(backup));
      expect(count, 3);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('app_theme'), 3);
      expect(prefs.getBool('reminder_enabled'), true);
      expect(prefs.getStringList('favorite_hadiths'), ['7', '14']);
    });

    test('rejects file from a different app', () async {
      final backup = makeBackup({}, app: 'some_other_app');
      expect(
        () => BackupService.importFromString(json.encode(backup)),
        throwsA(isA<BackupRestoreException>()),
      );
    });

    test('rejects future schema version', () async {
      final backup = makeBackup({}, schema: 999);
      expect(
        () => BackupService.importFromString(json.encode(backup)),
        throwsA(isA<BackupRestoreException>()),
      );
    });

    test('rejects malformed JSON', () {
      expect(
        () => BackupService.importFromString('{not json'),
        throwsA(isA<BackupRestoreException>()),
      );
    });

    test('rejects disallowed keys silently', () async {
      final backup = makeBackup({
        'app_theme': {'t': 'int', 'v': 1},
        'evil_key': {'t': 'string', 'v': 'pwned'},
      });
      final count = await BackupService.importFromString(json.encode(backup));
      expect(count, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('evil_key'), isFalse);
    });

    test('overwrite=false preserves existing keys', () async {
      SharedPreferences.setMockInitialValues({'app_theme': 0});
      final backup = makeBackup({
        'app_theme': {'t': 'int', 'v': 5},
        'reminder_enabled': {'t': 'bool', 'v': true},
      });

      final count = await BackupService.importFromString(
        json.encode(backup),
        overwrite: false,
      );
      expect(
        count,
        1,
        reason: 'Only the missing key (reminder_enabled) restored',
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('app_theme'), 0, reason: 'Existing value preserved');
      expect(prefs.getBool('reminder_enabled'), true);
    });

    test('roundtrip: export then import restores identical state', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme': 2,
        'reminder_enabled': true,
        'reminder_hour': 7,
        'reminder_minute': 30,
        'favorite_hadiths': ['1', '5'],
        'streak_current': 12,
        'streak_longest': 30,
      });

      final exported = await BackupService.exportToString();

      // Wipe.
      SharedPreferences.setMockInitialValues({});

      final count = await BackupService.importFromString(exported);
      expect(count, 7);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('app_theme'), 2);
      expect(prefs.getBool('reminder_enabled'), true);
      expect(prefs.getInt('reminder_hour'), 7);
      expect(prefs.getInt('reminder_minute'), 30);
      expect(prefs.getStringList('favorite_hadiths'), ['1', '5']);
      expect(prefs.getInt('streak_current'), 12);
      expect(prefs.getInt('streak_longest'), 30);
    });
  });
}
