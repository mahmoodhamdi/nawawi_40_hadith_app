import 'package:equatable/equatable.dart';

/// Kind of quiz question. We keep three types to give variety without
/// turning the experience into a game; each tests a *different* kind of
/// recall (who, where, which one).
enum QuizQuestionKind {
  /// "Who narrated hadith #N?" — choose the Sahabi's name.
  narrator,

  /// "From which collection is this hadith?" — choose Bukhari / Muslim / etc.
  collection,

  /// "Which hadith number is this?" — match a body excerpt to its index.
  hadithNumber,
}

class QuizQuestion extends Equatable {
  final QuizQuestionKind kind;

  /// Text shown to the user as the question prompt.
  final String prompt;

  /// All possible answers (shuffled). Index `correctIndex` is the right one.
  final List<String> choices;
  final int correctIndex;

  /// The hadith index (1-based) this question is built from — useful for
  /// post-quiz reviews ("you missed hadith N, want to read it now?").
  final int sourceHadithIndex;

  const QuizQuestion({
    required this.kind,
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    required this.sourceHadithIndex,
  });

  String get correctAnswer => choices[correctIndex];

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  @override
  List<Object?> get props => [
    kind,
    prompt,
    choices,
    correctIndex,
    sourceHadithIndex,
  ];
}
