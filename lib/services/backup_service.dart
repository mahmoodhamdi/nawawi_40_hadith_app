import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Local backup / restore — privacy-respecting (no cloud, no upload).
///
/// The user can export a JSON file of all their app preferences (favorites,
/// reading progress, streaks, notes, settings) via the share sheet, and
/// later restore from that same file. Restore is opt-in and overwrites
/// existing prefs by default; the import path validates the schema before
/// applying anything.
class BackupService {
  /// Schema version. Bump on breaking layout changes; restore refuses
  /// versions it doesn't recognize, preventing accidental data loss.
  static const int schemaVersion = 1;

  /// Allowlist of preference keys that are eligible for backup/restore.
  /// Anything outside this list is ignored on both export and import —
  /// this prevents arbitrary key injection from a tampered file.
  static const Set<String> allowedKeys = {
    PreferenceKeys.lastReadHadith,
    PreferenceKeys.lastReadTime,
    PreferenceKeys.theme,
    PreferenceKeys.hadithFontSize,
    PreferenceKeys.descriptionFontSize,
    PreferenceKeys.favorites,
    PreferenceKeys.readHadiths,
    PreferenceKeys.reminderEnabled,
    PreferenceKeys.reminderHour,
    PreferenceKeys.reminderMinute,
    PreferenceKeys.searchHistory,
    PreferenceKeys.streakLastDate,
    PreferenceKeys.streakCurrent,
    PreferenceKeys.streakLongest,
    PreferenceKeys.hadithNotes,
    'language', // LanguageCubit's stored key
  };

  /// Build the in-memory JSON snapshot of all backup-eligible preferences.
  ///
  /// Each value is recorded with its concrete type tag so restore can call
  /// the correct `prefs.setX` setter. We avoid using `Map<String, dynamic>`
  /// directly across persistence boundaries — typed entries are robust to
  /// JSON normalizing booleans / ints in surprising ways.
  static Future<Map<String, dynamic>> buildSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = <String, dynamic>{};

    for (final key in allowedKeys) {
      if (!prefs.containsKey(key)) continue;
      final value = prefs.get(key);
      if (value is bool) {
        entries[key] = {'t': 'bool', 'v': value};
      } else if (value is int) {
        entries[key] = {'t': 'int', 'v': value};
      } else if (value is double) {
        entries[key] = {'t': 'double', 'v': value};
      } else if (value is String) {
        entries[key] = {'t': 'string', 'v': value};
      } else if (value is List<String>) {
        entries[key] = {'t': 'stringList', 'v': value};
      } else {
        debugPrint('BackupService: skipping unsupported type for $key: ${value.runtimeType}');
      }
    }

    return {
      'app': 'nawawi_40_hadith_app',
      'schema': schemaVersion,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'entries': entries,
    };
  }

  /// Serialize the snapshot to JSON (pretty-printed for readability).
  static Future<String> exportToString() async {
    final snapshot = await buildSnapshot();
    return const JsonEncoder.withIndent('  ').convert(snapshot);
  }

  /// Write the backup to a temp file and trigger the OS share sheet.
  ///
  /// Returns the path to the written file on success. The user picks the
  /// destination — email to themselves, save to Files / Drive, send to a
  /// trusted contact, etc. Nothing about this flow contacts a server.
  static Future<String> shareBackup() async {
    final json = await exportToString();
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().toUtc().toIso8601String().split('T').first;
    final path = '${dir.path}/nawawi40-backup-$timestamp.json';
    final file = File(path);
    await file.writeAsString(json, flush: true);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(path, mimeType: 'application/json')],
      subject: 'Forty Hadith Nawawi — backup',
    ));

    return path;
  }

  /// Apply a backup string to SharedPreferences.
  ///
  /// Returns the number of keys restored. Throws [BackupRestoreException]
  /// with a user-displayable message on any validation failure — the
  /// caller (UI) is expected to surface this in a SnackBar.
  ///
  /// [overwrite] (default true) replaces existing values; if false, only
  /// missing keys are set.
  static Future<int> importFromString(
    String jsonString, {
    bool overwrite = true,
  }) async {
    final Map<String, dynamic> parsed;
    try {
      parsed = json.decode(jsonString) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw BackupRestoreException('Invalid JSON: ${e.message}');
    } on TypeError {
      throw const BackupRestoreException('Backup file root must be an object');
    }

    if (parsed['app'] != 'nawawi_40_hadith_app') {
      throw const BackupRestoreException(
        'This backup is not for Forty Hadith Nawawi',
      );
    }

    final schema = parsed['schema'];
    if (schema is! int) {
      throw const BackupRestoreException('Backup schema field missing or invalid');
    }
    if (schema > schemaVersion) {
      throw BackupRestoreException(
        'Backup is from a newer app version (schema $schema). '
        'Update the app and try again.',
      );
    }

    final entries = parsed['entries'];
    if (entries is! Map<String, dynamic>) {
      throw const BackupRestoreException('Backup is missing the entries object');
    }

    final prefs = await SharedPreferences.getInstance();
    var restored = 0;

    for (final entry in entries.entries) {
      final key = entry.key;
      if (!allowedKeys.contains(key)) continue;
      if (!overwrite && prefs.containsKey(key)) continue;

      final wrapped = entry.value;
      if (wrapped is! Map<String, dynamic>) continue;
      final type = wrapped['t'];
      final value = wrapped['v'];

      try {
        switch (type) {
          case 'bool':
            if (value is bool) {
              await prefs.setBool(key, value);
              restored++;
            }
            break;
          case 'int':
            if (value is int) {
              await prefs.setInt(key, value);
              restored++;
            }
            break;
          case 'double':
            if (value is double || value is int) {
              await prefs.setDouble(key, (value as num).toDouble());
              restored++;
            }
            break;
          case 'string':
            if (value is String) {
              await prefs.setString(key, value);
              restored++;
            }
            break;
          case 'stringList':
            if (value is List) {
              final asList = value.whereType<String>().toList();
              if (asList.length == value.length) {
                await prefs.setStringList(key, asList);
                restored++;
              }
            }
            break;
        }
      } catch (e) {
        debugPrint('BackupService: failed to restore $key: $e');
        // Continue with remaining keys.
      }
    }

    return restored;
  }
}

class BackupRestoreException implements Exception {
  final String message;
  const BackupRestoreException(this.message);
  @override
  String toString() => 'BackupRestoreException: $message';
}
