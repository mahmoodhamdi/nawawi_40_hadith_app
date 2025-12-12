import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';

void main() {
  group('Hadith Model', () {
    test('creates Hadith with required fields', () {
      final hadith = Hadith(
        hadith: 'الحديث الأول',
        description: 'شرح الحديث الأول',
      );

      expect(hadith.hadith, 'الحديث الأول');
      expect(hadith.description, 'شرح الحديث الأول');
    });

    test('creates Hadith from valid JSON', () {
      final json = {
        'hadith': 'الحديث الأول\nعن عمر بن الخطاب رضي الله عنه',
        'description': 'شرح الحديث',
      };

      final hadith = Hadith.fromJson(json);

      expect(hadith.hadith, json['hadith']);
      expect(hadith.description, json['description']);
    });

    test('creates Hadith from JSON with empty strings', () {
      final json = {
        'hadith': '',
        'description': '',
      };

      final hadith = Hadith.fromJson(json);

      expect(hadith.hadith, '');
      expect(hadith.description, '');
    });

    test('creates Hadith from JSON with long text', () {
      final longText = 'أ' * 10000;
      final json = {
        'hadith': longText,
        'description': longText,
      };

      final hadith = Hadith.fromJson(json);

      expect(hadith.hadith.length, 10000);
      expect(hadith.description.length, 10000);
    });

    test('creates Hadith from JSON with special characters', () {
      final json = {
        'hadith': 'الحديث مع علامات: "نص" و (قوسين) و ؟!',
        'description': 'شرح مع أرقام: ١٢٣٤٥٦٧٨٩٠',
      };

      final hadith = Hadith.fromJson(json);

      expect(hadith.hadith, json['hadith']);
      expect(hadith.description, json['description']);
    });

    test('throws when JSON missing hadith field', () {
      final json = {
        'description': 'شرح الحديث',
      };

      expect(
        () => Hadith.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws when JSON missing description field', () {
      final json = {
        'hadith': 'الحديث',
      };

      expect(
        () => Hadith.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws when hadith field is not a string', () {
      final json = {
        'hadith': 123,
        'description': 'شرح',
      };

      expect(
        () => Hadith.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws when description field is not a string', () {
      final json = {
        'hadith': 'الحديث',
        'description': null,
      };

      expect(
        () => Hadith.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
