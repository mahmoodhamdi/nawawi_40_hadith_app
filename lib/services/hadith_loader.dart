import 'dart:convert';
import 'package:flutter/services.dart';
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
  static const String _assetPath = 'assets/json/40-hadith-nawawi.json';

  /// Loads all hadiths from the JSON asset file
  ///
  /// Throws [HadithLoadException] if:
  /// - The asset file cannot be found or read
  /// - The JSON format is invalid
  /// - The data structure doesn't match expected format
  static Future<List<Hadith>> loadHadiths() async {
    try {
      final String jsonString = await rootBundle.loadString(_assetPath);

      final dynamic decoded = json.decode(jsonString);

      if (decoded is! List) {
        throw HadithLoadException(
          'تنسيق البيانات غير صحيح: المتوقع قائمة من الأحاديث',
        );
      }

      final List<dynamic> jsonList = decoded;

      if (jsonList.isEmpty) {
        throw HadithLoadException('ملف البيانات فارغ');
      }

      return jsonList.map((item) {
        if (item is! Map<String, dynamic>) {
          throw HadithLoadException(
            'تنسيق الحديث غير صحيح',
            item,
          );
        }
        return Hadith.fromJson(item);
      }).toList();

    } on FormatException catch (e) {
      throw HadithLoadException(
        'خطأ في تنسيق ملف JSON',
        e,
      );
    } catch (e) {
      if (e is HadithLoadException) rethrow;
      // Handle asset loading errors and other unexpected errors
      final errorMessage = e.toString().contains('Unable to load asset')
          ? 'فشل تحميل ملف البيانات'
          : 'خطأ غير متوقع أثناء تحميل الأحاديث';
      throw HadithLoadException(errorMessage, e);
    }
  }
}
