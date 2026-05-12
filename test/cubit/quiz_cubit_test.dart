import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/cubit/quiz_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/quiz_state.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';

List<Hadith> _hadiths(int n) {
  return List<Hadith>.generate(n, (i) {
    final idx = i + 1;
    return Hadith(
      titleAr: 'العنوان $idx',
      titleEn: 'Title $idx',
      hadithAr: 'الحديث $idx\n"النص $idx"',
      hadithEn: 'Hadith $idx\n"Body $idx"',
      descriptionAr: 'شرح',
      descriptionEn: 'desc',
      citation: HadithCitation(
        number: idx,
        narratorAr: 'راوي $idx',
        narratorEn: 'Narrator $idx',
        collectionAr: 'البخاري',
        collectionEn: 'al-Bukhari',
        sunnahUrl: 'https://sunnah.com/nawawi40:$idx',
      ),
    );
  });
}

void main() {
  group('QuizCubit', () {
    test('starts in idle phase', () {
      final cubit = QuizCubit();
      expect(cubit.state.phase, QuizPhase.idle);
      expect(cubit.state.questions, isEmpty);
    });

    test('start() generates questions and switches to inProgress', () {
      final cubit = QuizCubit(rng: Random(1));
      cubit.start(hadiths: _hadiths(10), count: 5);
      expect(cubit.state.phase, QuizPhase.inProgress);
      expect(cubit.state.questions.length, 5);
      expect(cubit.state.currentIndex, 0);
    });

    test('start() with empty hadith list stays idle', () {
      final cubit = QuizCubit(rng: Random(1));
      cubit.start(hadiths: const [], count: 5);
      expect(cubit.state.phase, QuizPhase.idle);
    });

    test('answer() advances through questions', () {
      final cubit = QuizCubit(rng: Random(7));
      cubit.start(hadiths: _hadiths(15), count: 3);
      expect(cubit.state.currentIndex, 0);
      cubit.answer(0);
      expect(cubit.state.currentIndex, 1);
      cubit.answer(1);
      expect(cubit.state.currentIndex, 2);
      cubit.answer(2);
      expect(cubit.state.phase, QuizPhase.finished);
    });

    test('answer() outside inProgress phase is a no-op', () {
      final cubit = QuizCubit();
      cubit.answer(0);
      expect(cubit.state.phase, QuizPhase.idle);
      expect(cubit.state.answers, isEmpty);
    });

    test('correctCount reflects matching answers', () {
      final cubit = QuizCubit(rng: Random(11));
      cubit.start(hadiths: _hadiths(20), count: 4);
      // Always answer with the correct index — gives a perfect score.
      while (cubit.state.phase == QuizPhase.inProgress) {
        cubit.answer(cubit.state.currentQuestion!.correctIndex);
      }
      expect(cubit.state.correctCount, 4);
      expect(cubit.state.totalAnswered, 4);
    });

    test('correctCount is 0 when every answer is wrong', () {
      final cubit = QuizCubit(rng: Random(22));
      cubit.start(hadiths: _hadiths(20), count: 4);
      while (cubit.state.phase == QuizPhase.inProgress) {
        final correct = cubit.state.currentQuestion!.correctIndex;
        cubit.answer(correct == 0 ? 1 : 0);
      }
      expect(cubit.state.correctCount, 0);
    });

    test('reset() returns to idle and clears questions', () {
      final cubit = QuizCubit(rng: Random(33));
      cubit.start(hadiths: _hadiths(10), count: 3);
      cubit.reset();
      expect(cubit.state.phase, QuizPhase.idle);
      expect(cubit.state.questions, isEmpty);
      expect(cubit.state.answers, isEmpty);
    });
  });
}
