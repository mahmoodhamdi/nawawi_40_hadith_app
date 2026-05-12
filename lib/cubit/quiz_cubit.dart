import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/hadith.dart';
import '../services/quiz_generator.dart';
import 'quiz_state.dart';

/// Drives a single quiz session. State is session-only (no SharedPreferences)
/// — quizzes are a fleeting learning exercise; persisting them across app
/// restarts would just clutter the user's prefs surface for marginal value.
class QuizCubit extends Cubit<QuizState> {
  /// Optional Random injection — tests pin the seed to assert specific
  /// question generation; production uses time-based default.
  final Random _rng;

  QuizCubit({Random? rng})
      : _rng = rng ?? Random(),
        super(const QuizState());

  /// Start a new session with [count] questions built from [hadiths].
  void start({
    required List<Hadith> hadiths,
    int count = QuizGenerator.defaultSessionSize,
    bool arabic = true,
  }) {
    final questions = QuizGenerator.generate(
      hadiths: hadiths,
      count: count,
      rng: _rng,
      arabic: arabic,
    );
    emit(QuizState(
      phase: questions.isEmpty ? QuizPhase.idle : QuizPhase.inProgress,
      questions: questions,
      answers: const [],
      currentIndex: 0,
    ));
  }

  /// Submit the user's selection for the current question and advance.
  /// If this was the last question, the session transitions to `finished`.
  void answer(int choiceIndex) {
    if (state.phase != QuizPhase.inProgress) return;
    final updatedAnswers = [...state.answers, choiceIndex];
    final nextIndex = state.currentIndex + 1;
    final isLast = nextIndex >= state.questions.length;
    emit(state.copyWith(
      answers: updatedAnswers,
      currentIndex: nextIndex,
      phase: isLast ? QuizPhase.finished : QuizPhase.inProgress,
    ));
  }

  /// Reset to idle without preserving any state. Useful for "Try again".
  void reset() => emit(const QuizState());
}
