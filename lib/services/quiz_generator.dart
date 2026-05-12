import 'dart:math';

import '../models/hadith.dart';
import '../models/quiz_question.dart';

/// Builds quiz sessions from the loaded hadith collection.
///
/// Pure functions only — no I/O, no global state. The randomness is
/// injectable via a [Random] instance so tests can pin the seed and
/// assert exact output.
class QuizGenerator {
  static const int defaultSessionSize = 10;
  static const int choicesPerQuestion = 4;

  /// Build [count] questions from [hadiths]. Each question is on a
  /// distinct hadith; if [count] > available hadiths, capped to all.
  static List<QuizQuestion> generate({
    required List<Hadith> hadiths,
    int count = defaultSessionSize,
    Random? rng,
    bool arabic = true,
  }) {
    final r = rng ?? Random();
    if (hadiths.isEmpty) return const [];

    final actualCount = count.clamp(1, hadiths.length);

    // Pick distinct source-hadith indices.
    final indices = List<int>.generate(hadiths.length, (i) => i)..shuffle(r);
    final picked = indices.take(actualCount).toList();

    final questions = <QuizQuestion>[];
    for (final idx in picked) {
      final hadith = hadiths[idx];
      // Cycle through kinds so each session has variety. We rotate based
      // on the question's position so a 10-question session naturally
      // covers all three kinds.
      final kind =
          QuizQuestionKind.values[questions.length % QuizQuestionKind.values.length];
      final question = _buildQuestion(
        kind: kind,
        sourceIndex: idx + 1, // 1-based public index
        hadith: hadith,
        allHadiths: hadiths,
        rng: r,
        arabic: arabic,
      );
      if (question != null) questions.add(question);
    }
    return questions;
  }

  static QuizQuestion? _buildQuestion({
    required QuizQuestionKind kind,
    required int sourceIndex,
    required Hadith hadith,
    required List<Hadith> allHadiths,
    required Random rng,
    required bool arabic,
  }) {
    switch (kind) {
      case QuizQuestionKind.narrator:
        if (hadith.citation == null) {
          return _buildQuestion(
            kind: QuizQuestionKind.hadithNumber,
            sourceIndex: sourceIndex,
            hadith: hadith,
            allHadiths: allHadiths,
            rng: rng,
            arabic: arabic,
          );
        }
        return _narratorQuestion(sourceIndex, hadith, allHadiths, rng, arabic);

      case QuizQuestionKind.collection:
        if (hadith.citation == null) {
          return _buildQuestion(
            kind: QuizQuestionKind.hadithNumber,
            sourceIndex: sourceIndex,
            hadith: hadith,
            allHadiths: allHadiths,
            rng: rng,
            arabic: arabic,
          );
        }
        return _collectionQuestion(sourceIndex, hadith, allHadiths, rng, arabic);

      case QuizQuestionKind.hadithNumber:
        return _hadithNumberQuestion(sourceIndex, hadith, allHadiths, rng, arabic);
    }
  }

  static QuizQuestion _narratorQuestion(
    int sourceIndex,
    Hadith hadith,
    List<Hadith> allHadiths,
    Random rng,
    bool arabic,
  ) {
    final correct = arabic
        ? hadith.citation!.narratorAr
        : hadith.citation!.narratorEn;

    // Find distractor narrators from other hadiths, distinct from correct.
    final pool = allHadiths
        .where((h) => h.citation != null)
        .map((h) => arabic ? h.citation!.narratorAr : h.citation!.narratorEn)
        .toSet()
      ..remove(correct);

    // If we can't produce 3 distractors of this type, fall back to a
    // hadithNumber question — that source has 41 possible distractors.
    if (pool.length < choicesPerQuestion - 1) {
      return _hadithNumberQuestion(sourceIndex, hadith, allHadiths, rng, arabic);
    }

    final distractors = (pool.toList()..shuffle(rng))
        .take(choicesPerQuestion - 1)
        .toList();

    final choices = [...distractors, correct]..shuffle(rng);
    final correctIndex = choices.indexOf(correct);

    final prompt = arabic
        ? 'من راوي الحديث رقم $sourceIndex؟'
        : 'Who narrated Hadith #$sourceIndex?';

    return QuizQuestion(
      kind: QuizQuestionKind.narrator,
      prompt: prompt,
      choices: choices,
      correctIndex: correctIndex,
      sourceHadithIndex: sourceIndex,
    );
  }

  static QuizQuestion _collectionQuestion(
    int sourceIndex,
    Hadith hadith,
    List<Hadith> allHadiths,
    Random rng,
    bool arabic,
  ) {
    final correct = arabic
        ? hadith.citation!.collectionAr
        : hadith.citation!.collectionEn;

    final pool = allHadiths
        .where((h) => h.citation != null)
        .map((h) => arabic ? h.citation!.collectionAr : h.citation!.collectionEn)
        .toSet()
      ..remove(correct);

    // Same guard as narrator — fall back if we can't produce enough
    // distractor collections (e.g. only 2 collections in the data).
    if (pool.length < choicesPerQuestion - 1) {
      return _hadithNumberQuestion(sourceIndex, hadith, allHadiths, rng, arabic);
    }

    final distractors = (pool.toList()..shuffle(rng))
        .take(choicesPerQuestion - 1)
        .toList();
    final choices = [...distractors, correct]..shuffle(rng);
    final correctIndex = choices.indexOf(correct);

    final prompt = arabic
        ? 'من رواة الحديث رقم $sourceIndex (المصدر)؟'
        : 'Which collection contains Hadith #$sourceIndex?';

    return QuizQuestion(
      kind: QuizQuestionKind.collection,
      prompt: prompt,
      choices: choices,
      correctIndex: correctIndex,
      sourceHadithIndex: sourceIndex,
    );
  }

  static QuizQuestion _hadithNumberQuestion(
    int sourceIndex,
    Hadith hadith,
    List<Hadith> allHadiths,
    Random rng,
    bool arabic,
  ) {
    // Extract a short excerpt — first sentence between the quote marks if
    // present, else the first ~80 chars of the body (after stripping the
    // "الحديث الأول" leader line).
    final body = arabic ? hadith.hadithAr : hadith.hadithEn;
    final lines = body.split('\n');
    final rest = lines.length > 1 ? lines.skip(1).join(' ').trim() : body.trim();
    final quoteMatch =
        RegExp(r'["“«]([^"”»]{20,200})["”»]').firstMatch(rest);
    final excerpt = quoteMatch != null
        ? quoteMatch.group(1)!.trim()
        : (rest.length > 120 ? '${rest.substring(0, 117)}...' : rest);

    // Generate 3 distractor indices.
    final pool = List<int>.generate(allHadiths.length, (i) => i + 1)
      ..remove(sourceIndex)
      ..shuffle(rng);
    final distractorIndices = pool.take(choicesPerQuestion - 1).toList();

    final indices = [...distractorIndices, sourceIndex]..shuffle(rng);
    final choices = indices
        .map((i) => arabic ? 'الحديث رقم $i' : 'Hadith #$i')
        .toList();
    final correctIndex = indices.indexOf(sourceIndex);

    final prompt = arabic
        ? 'ينتمي هذا النص إلى أي حديث؟\n\n"$excerpt"'
        : 'This excerpt is from which hadith?\n\n"$excerpt"';

    return QuizQuestion(
      kind: QuizQuestionKind.hadithNumber,
      prompt: prompt,
      choices: choices,
      correctIndex: correctIndex,
      sourceHadithIndex: sourceIndex,
    );
  }
}
