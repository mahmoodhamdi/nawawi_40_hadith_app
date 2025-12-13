import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';

void main() {
  group('Hadith Model', () {
    test('creates Hadith with required fields', () {
      final hadith = Hadith(
        titleAr: 'الأعمال بالنيات',
        titleEn: 'Actions Are By Intentions',
        hadithAr: 'الحديث الأول',
        hadithEn: 'First hadith',
        descriptionAr: 'شرح الحديث الأول',
        descriptionEn: 'First hadith explanation',
      );

      expect(hadith.titleAr, 'الأعمال بالنيات');
      expect(hadith.titleEn, 'Actions Are By Intentions');
      expect(hadith.hadithAr, 'الحديث الأول');
      expect(hadith.hadithEn, 'First hadith');
      expect(hadith.descriptionAr, 'شرح الحديث الأول');
      expect(hadith.descriptionEn, 'First hadith explanation');
      // Test legacy getters
      expect(hadith.title, 'الأعمال بالنيات');
      expect(hadith.hadith, 'الحديث الأول');
      expect(hadith.description, 'شرح الحديث الأول');
    });

    test('getHadith returns correct language text', () {
      final hadith = Hadith(
        titleAr: 'العنوان',
        titleEn: 'Title',
        hadithAr: 'الحديث بالعربية',
        hadithEn: 'Hadith in English',
        descriptionAr: 'شرح بالعربية',
        descriptionEn: 'Explanation in English',
      );

      expect(hadith.getHadith('ar'), 'الحديث بالعربية');
      expect(hadith.getHadith('en'), 'Hadith in English');
    });

    test('getDescription returns correct language text', () {
      final hadith = Hadith(
        titleAr: 'العنوان',
        titleEn: 'Title',
        hadithAr: 'الحديث',
        hadithEn: 'Hadith',
        descriptionAr: 'شرح بالعربية',
        descriptionEn: 'Explanation in English',
      );

      expect(hadith.getDescription('ar'), 'شرح بالعربية');
      expect(hadith.getDescription('en'), 'Explanation in English');
    });

    test('getTitle returns correct language text', () {
      final hadith = Hadith(
        titleAr: 'العنوان بالعربية',
        titleEn: 'Title in English',
        hadithAr: 'الحديث',
        hadithEn: 'Hadith',
        descriptionAr: 'شرح',
        descriptionEn: 'Explanation',
      );

      expect(hadith.getTitle('ar'), 'العنوان بالعربية');
      expect(hadith.getTitle('en'), 'Title in English');
    });

    test('creates Hadith from valid Arabic JSON', () {
      final json = {
        'hadith': 'الحديث الأول\nعن عمر بن الخطاب رضي الله عنه',
        'description': 'شرح الحديث',
      };

      final hadith = Hadith.fromJson(json);

      expect(hadith.hadithAr, json['hadith']);
      expect(hadith.descriptionAr, json['description']);
      // English falls back to Arabic when not provided
      expect(hadith.hadithEn, json['hadith']);
      expect(hadith.descriptionEn, json['description']);
    });

    test('creates Hadith from Arabic and English JSON', () {
      final jsonAr = {
        'hadith': 'الحديث بالعربية',
        'description': 'شرح بالعربية',
      };
      final jsonEn = {
        'hadith': 'Hadith in English',
        'description': 'Explanation in English',
      };

      final hadith = Hadith.fromJson(jsonAr, jsonEn);

      expect(hadith.hadithAr, 'الحديث بالعربية');
      expect(hadith.hadithEn, 'Hadith in English');
      expect(hadith.descriptionAr, 'شرح بالعربية');
      expect(hadith.descriptionEn, 'Explanation in English');
    });

    test('creates Hadith from JSON with empty strings', () {
      final json = {
        'hadith': '',
        'description': '',
      };

      final hadith = Hadith.fromJson(json);

      expect(hadith.hadithAr, '');
      expect(hadith.descriptionAr, '');
    });

    test('creates Hadith from JSON with long text', () {
      final longText = 'أ' * 10000;
      final json = {
        'hadith': longText,
        'description': longText,
      };

      final hadith = Hadith.fromJson(json);

      expect(hadith.hadithAr.length, 10000);
      expect(hadith.descriptionAr.length, 10000);
    });

    test('creates Hadith from JSON with special characters', () {
      final json = {
        'hadith': 'الحديث مع علامات: "نص" و (قوسين) و ؟!',
        'description': 'شرح مع أرقام: ١٢٣٤٥٦٧٨٩٠',
      };

      final hadith = Hadith.fromJson(json);

      expect(hadith.hadithAr, json['hadith']);
      expect(hadith.descriptionAr, json['description']);
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

    test('creates Hadith using fromBilingual factory', () {
      final hadith = Hadith.fromBilingual(
        titleAr: 'العنوان',
        titleEn: 'Title',
        hadithAr: 'الحديث',
        hadithEn: 'Hadith',
        descriptionAr: 'شرح',
        descriptionEn: 'Explanation',
      );

      expect(hadith.titleAr, 'العنوان');
      expect(hadith.titleEn, 'Title');
      expect(hadith.hadithAr, 'الحديث');
      expect(hadith.hadithEn, 'Hadith');
      expect(hadith.descriptionAr, 'شرح');
      expect(hadith.descriptionEn, 'Explanation');
    });
  });
}
