import 'package:equatable/equatable.dart';

import '../models/quiz_question.dart';

enum QuizPhase { idle, inProgress, finished }

class QuizState extends Equatable {
  final QuizPhase phase;
  final List<QuizQuestion> questions;

  /// Answers user has submitted so far, by question index. -1 means
  /// "answered with no selection" (skip), which we currently disallow at
  /// the UI level — included for forward-compatibility.
  final List<int> answers;

  /// Index of the question currently shown. Invalid once phase=finished.
  final int currentIndex;

  const QuizState({
    this.phase = QuizPhase.idle,
    this.questions = const [],
    this.answers = const [],
    this.currentIndex = 0,
  });

  QuizState copyWith({
    QuizPhase? phase,
    List<QuizQuestion>? questions,
    List<int>? answers,
    int? currentIndex,
  }) {
    return QuizState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  QuizQuestion? get currentQuestion {
    if (phase != QuizPhase.inProgress) return null;
    if (currentIndex < 0 || currentIndex >= questions.length) return null;
    return questions[currentIndex];
  }

  int get correctCount {
    var n = 0;
    for (var i = 0; i < answers.length && i < questions.length; i++) {
      if (questions[i].isCorrect(answers[i])) n++;
    }
    return n;
  }

  int get totalAnswered => answers.length;

  @override
  List<Object?> get props => [phase, questions, answers, currentIndex];
}
