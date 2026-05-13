import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';
import 'package:hadith_nawawi_audio/services/search_service.dart';

Hadith _h({
  String hadithAr = '',
  String titleAr = '',
  String descriptionAr = '',
  List<String> topicsAr = const [],
  HadithCitation? citation,
}) {
  return Hadith(
    titleAr: titleAr,
    titleEn: '',
    hadithAr: hadithAr,
    hadithEn: '',
    descriptionAr: descriptionAr,
    descriptionEn: '',
    citation: citation,
    topicIds: List.generate(topicsAr.length, (i) => 't$i'),
    topicLabelsAr: topicsAr,
    topicLabelsEn: topicsAr,
  );
}

void main() {
  group('SearchService.normalize', () {
    test('strips diacritics', () {
      expect(
        SearchService.normalize('إنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ'),
        'انما الاعمال بالنيات',
      );
    });

    test('folds alef variants and ya variants', () {
      expect(SearchService.normalize('آدم'), 'ادم');
      expect(SearchService.normalize('أحمد'), 'احمد');
      expect(SearchService.normalize('إسلام'), 'اسلام');
      expect(SearchService.normalize('ى'), 'ي');
      expect(SearchService.normalize('شيخ'), 'شيخ');
    });

    test('folds taa marbuta', () {
      expect(SearchService.normalize('نية'), 'نيه');
    });

    test('latin input is lowercased', () {
      expect(SearchService.normalize('NIYYAH'), 'niyyah');
    });
  });

  group('SearchService.transliterateQuery', () {
    test('returns Arabic equivalent for common terms', () {
      expect(SearchService.transliterateQuery('niyyah'), 'نية');
      expect(SearchService.transliterateQuery('iman'), 'إيمان');
      expect(SearchService.transliterateQuery('nawawi'), 'نووي');
      expect(SearchService.transliterateQuery('bukhari'), 'بخاري');
    });

    test('passes through Arabic input untouched', () {
      expect(SearchService.transliterateQuery('نية'), 'نية');
    });

    test('translates word-by-word', () {
      expect(SearchService.transliterateQuery('umar ibn'), 'عمر ابن');
    });

    test('handles unknown terms by passing them through', () {
      expect(SearchService.transliterateQuery('gobbledygook'), 'gobbledygook');
    });

    test('handles empty input', () {
      expect(SearchService.transliterateQuery(''), '');
      expect(SearchService.transliterateQuery('   '), '   ');
    });
  });

  group('SearchService.levenshtein', () {
    test('zero for identical', () {
      expect(SearchService.levenshtein('abc', 'abc'), 0);
    });

    test('correct for empty inputs', () {
      expect(SearchService.levenshtein('', 'abc'), 3);
      expect(SearchService.levenshtein('abc', ''), 3);
      expect(SearchService.levenshtein('', ''), 0);
    });

    test('one for single-letter substitution', () {
      expect(SearchService.levenshtein('cat', 'bat'), 1);
    });

    test('matches the classic kitten/sitting example', () {
      expect(SearchService.levenshtein('kitten', 'sitting'), 3);
    });
  });

  group('SearchService.fuzzyMatch', () {
    test('exact substring matches', () {
      expect(SearchService.fuzzyMatch('نية', 'إنما الأعمال بالنية'), isTrue);
    });

    test('rejects very short fuzzy queries', () {
      // 'abc' is 3 chars; no fuzz allowed.
      expect(SearchService.fuzzyMatch('abx', 'abc'), isFalse);
    });

    test('matches with one-character distance for medium queries', () {
      expect(SearchService.fuzzyMatch('niyyaa', 'niyyah'), isTrue);
    });

    test('rejects when distance exceeds default threshold', () {
      expect(SearchService.fuzzyMatch('niyyabbb', 'niyyah'), isFalse);
    });
  });

  group('SearchService.stem', () {
    test('strips definite article + plural suffix', () {
      // After normalization "بالنيات" → "بالنيات" → strip "بال" → "نيات"
      //                                     → strip "ات" → "ني"
      expect(SearchService.stem(SearchService.normalize('بالنيات')), 'ني');
    });

    test('strips ـكم suffix from "أحدكم"', () {
      expect(SearchService.stem(SearchService.normalize('أحدكم')), 'احد');
    });

    test('reduces "نية" and "بالنيات" to same stem', () {
      expect(
        SearchService.stem(SearchService.normalize('نية')),
        SearchService.stem(SearchService.normalize('بالنيات')),
      );
    });

    test('leaves short tokens unchanged', () {
      expect(SearchService.stem('ال'), 'ال');
      expect(SearchService.stem('من'), 'من');
    });
  });

  group('SearchService.matches', () {
    test('matches hadith text directly (singular form)', () {
      final h = _h(hadithAr: 'القلب محل النية والإخلاص');
      expect(SearchService.matches('نية', h), isTrue);
    });

    test('matches plural form via stemming', () {
      // The actual prophetic hadith uses "بالنيات" (plural);
      // a user searching "نية" should still find it via stemming.
      final h = _h(hadithAr: 'إنما الأعمال بالنيات');
      expect(SearchService.matches('نية', h), isTrue);
    });

    test('matches via title', () {
      final h = _h(titleAr: 'الأعمال بالنيات');
      expect(SearchService.matches('بالنيات', h), isTrue);
    });

    test('matches via topic label', () {
      final h = _h(topicsAr: ['النية', 'الإخلاص']);
      expect(SearchService.matches('الإخلاص', h), isTrue);
    });

    test('matches via Latin transliteration', () {
      // "niyyah" → translit → "نية" → stems to same root as the actual
      // prophetic text "بالنيات", so the search now works on the
      // canonical body too (no longer needs the singular form).
      final h = _h(hadithAr: 'إنما الأعمال بالنيات');
      expect(SearchService.matches('niyyah', h), isTrue);
    });

    test('matches via citation narrator', () {
      final h = _h(
        hadithAr: 'x',
        citation: const HadithCitation(
          number: 1,
          narratorAr: 'عمر بن الخطاب',
          narratorEn: 'Umar ibn al-Khattab',
          collectionAr: 'البخاري ومسلم',
          collectionEn: 'al-Bukhari and Muslim',
          sunnahUrl: 'https://sunnah.com/nawawi40:1',
        ),
      );
      expect(SearchService.matches('umar', h), isTrue);
    });

    test('empty query matches all', () {
      final h = _h();
      expect(SearchService.matches('', h), isTrue);
      expect(SearchService.matches('   ', h), isTrue);
    });

    test('no match returns false', () {
      final h = _h(hadithAr: 'إنما الأعمال بالنيات');
      expect(SearchService.matches('xyzzy', h), isFalse);
    });
  });
}
