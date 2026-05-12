import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';
import 'package:hadith_nawawi_audio/models/quiz_question.dart';
import 'package:hadith_nawawi_audio/services/quiz_generator.dart';

List<Hadith> _makeHadiths(int n) {
  // Build a synthetic but plausible set with citations so all three
  // question kinds can be produced. Collections cycle through 4 distinct
  // values so the distractor pool for the "collection" question kind
  // always has ≥ 3 alternatives to pick from (otherwise the question
  // would produce < 4 choices).
  const collectionsAr = ['البخاري', 'مسلم', 'الترمذي', 'أبو داود', 'النسائي'];
  const collectionsEn = ['al-Bukhari', 'Muslim', 'al-Tirmidhi', 'Abu Dawud', 'al-Nasai'];
  return List<Hadith>.generate(n, (i) {
    final idx = i + 1;
    final bucket = i % collectionsAr.length;
    return Hadith(
      titleAr: 'العنوان $idx',
      titleEn: 'Title $idx',
      hadithAr: 'الحديث $idx\n"إنما الأعمال بالنيات رقم $idx" (رواه فلان)',
      hadithEn: 'Hadith $idx\n"Actions are by intentions no. $idx" (narrated)',
      descriptionAr: 'شرح $idx',
      descriptionEn: 'Description $idx',
      citation: HadithCitation(
        number: idx,
        narratorAr: 'الراوي $idx',
        narratorEn: 'Narrator $idx',
        collectionAr: collectionsAr[bucket],
        collectionEn: collectionsEn[bucket],
        sunnahUrl: 'https://sunnah.com/nawawi40:$idx',
      ),
    );
  });
}

void main() {
  group('QuizGenerator.generate', () {
    test('returns at most [count] questions', () {
      final hadiths = _makeHadiths(42);
      final questions =
          QuizGenerator.generate(hadiths: hadiths, count: 10, rng: Random(42));
      expect(questions.length, 10);
    });

    test('caps at total hadiths if count exceeds available', () {
      final hadiths = _makeHadiths(5);
      final questions =
          QuizGenerator.generate(hadiths: hadiths, count: 50, rng: Random(1));
      expect(questions.length, 5);
    });

    test('returns empty list for empty input', () {
      expect(QuizGenerator.generate(hadiths: const [], count: 5), isEmpty);
    });

    test('every question has exactly 4 choices', () {
      final hadiths = _makeHadiths(20);
      final questions =
          QuizGenerator.generate(hadiths: hadiths, count: 10, rng: Random(7));
      for (final q in questions) {
        expect(q.choices.length, QuizGenerator.choicesPerQuestion);
      }
    });

    test('correctIndex is valid in every question', () {
      final hadiths = _makeHadiths(20);
      final questions =
          QuizGenerator.generate(hadiths: hadiths, count: 10, rng: Random(13));
      for (final q in questions) {
        expect(q.correctIndex, inInclusiveRange(0, q.choices.length - 1));
      }
    });

    test('each question references a unique source hadith', () {
      final hadiths = _makeHadiths(42);
      final questions =
          QuizGenerator.generate(hadiths: hadiths, count: 10, rng: Random(99));
      final indices = questions.map((q) => q.sourceHadithIndex).toSet();
      expect(indices.length, questions.length,
          reason: 'No two questions should share the same source hadith');
    });

    test('cycles through all three question kinds in a 10-question session', () {
      final hadiths = _makeHadiths(42);
      final questions =
          QuizGenerator.generate(hadiths: hadiths, count: 10, rng: Random(5));
      final kinds = questions.map((q) => q.kind).toSet();
      expect(kinds, containsAll(QuizQuestionKind.values));
    });

    test('seeded rng produces deterministic output', () {
      final hadiths = _makeHadiths(42);
      final a =
          QuizGenerator.generate(hadiths: hadiths, count: 10, rng: Random(2026));
      final b =
          QuizGenerator.generate(hadiths: hadiths, count: 10, rng: Random(2026));
      expect(a, b);
    });

    test('falls back to hadithNumber kind for hadiths without citation', () {
      final hadiths = _makeHadiths(20)
          .map((h) => Hadith.fromBilingual(
                titleAr: h.titleAr,
                titleEn: h.titleEn,
                hadithAr: h.hadithAr,
                hadithEn: h.hadithEn,
                descriptionAr: h.descriptionAr,
                descriptionEn: h.descriptionEn,
                // no citation
              ))
          .toList();
      final questions =
          QuizGenerator.generate(hadiths: hadiths, count: 10, rng: Random(11));
      expect(questions, isNotEmpty);
      // All questions should be hadithNumber since others require citation.
      for (final q in questions) {
        expect(q.kind, QuizQuestionKind.hadithNumber);
      }
    });

    test('English mode produces English prompt prefix', () {
      final hadiths = _makeHadiths(20);
      final questions = QuizGenerator.generate(
          hadiths: hadiths, count: 5, rng: Random(3), arabic: false);
      for (final q in questions) {
        // English prompts use # for hadith number references.
        expect(
            q.prompt,
            anyOf(
              contains('Hadith'),
              contains('narrated'),
              contains('collection'),
              contains('excerpt'),
            ));
      }
    });
  });
}
