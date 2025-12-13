import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../models/hadith.dart';

/// Custom exception for hadith loading errors
class HadithLoadException implements Exception {
  final String message;
  final dynamic originalError;

  HadithLoadException(this.message, [this.originalError]);

  @override
  String toString() => 'HadithLoadException: $message';
}

/// Service responsible for loading hadith data from assets
class HadithLoader {
  /// Path to Arabic hadiths JSON
  static const String _arabicPath = AssetPaths.hadithJson;

  /// Path to English hadiths JSON
  static const String _englishPath = 'assets/json/40-hadith-nawawi-en.json';

  /// Loads all hadiths from both Arabic and English JSON asset files
  ///
  /// Throws [HadithLoadException] if:
  /// - The asset file cannot be found or read
  /// - The JSON format is invalid
  /// - The data structure doesn't match expected format
  static Future<List<Hadith>> loadHadiths() async {
    try {
      // Load Arabic hadiths (required)
      final String arabicJson = await rootBundle.loadString(_arabicPath);
      final List<dynamic> arabicList = _parseJsonList(arabicJson, 'Arabic');

      // Try to load English hadiths (optional)
      List<dynamic>? englishList;
      try {
        final String englishJson = await rootBundle.loadString(_englishPath);
        englishList = _parseJsonList(englishJson, 'English');
      } catch (e) {
        // English file is optional, continue with Arabic only
        debugPrint('English hadiths not available: $e');
      }

      // Merge Arabic and English hadiths
      return _mergeHadiths(arabicList, englishList);
    } on FormatException catch (e) {
      throw HadithLoadException(
        'خطأ في تنسيق ملف JSON / JSON format error',
        e,
      );
    } catch (e) {
      if (e is HadithLoadException) rethrow;
      final errorMessage = e.toString().contains('Unable to load asset')
          ? 'فشل تحميل ملف البيانات / Failed to load data file'
          : 'خطأ غير متوقع أثناء تحميل الأحاديث / Unexpected error loading hadiths';
      throw HadithLoadException(errorMessage, e);
    }
  }

  /// Parse JSON string into a list
  static List<dynamic> _parseJsonList(String jsonString, String source) {
    final dynamic decoded = json.decode(jsonString);

    if (decoded is! List) {
      throw HadithLoadException(
        'تنسيق البيانات غير صحيح ($source): المتوقع قائمة من الأحاديث',
      );
    }

    if (decoded.isEmpty) {
      throw HadithLoadException('ملف البيانات فارغ ($source)');
    }

    return decoded;
  }

  /// Merge Arabic and English hadith lists
  static List<Hadith> _mergeHadiths(
    List<dynamic> arabicList,
    List<dynamic>? englishList,
  ) {
    final List<Hadith> hadiths = [];

    for (int i = 0; i < arabicList.length; i++) {
      final arabicItem = arabicList[i];

      if (arabicItem is! Map<String, dynamic>) {
        throw HadithLoadException(
          'تنسيق الحديث غير صحيح (index: $i)',
          arabicItem,
        );
      }

      Map<String, dynamic>? englishItem;
      if (englishList != null && i < englishList.length) {
        final item = englishList[i];
        if (item is Map<String, dynamic>) {
          englishItem = item;
        }
      }

      hadiths.add(Hadith.fromJson(arabicItem, englishItem));
    }

    return hadiths;
  }
}
