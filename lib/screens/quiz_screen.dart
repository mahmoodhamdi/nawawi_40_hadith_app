import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/l10n/app_localizations.dart';
import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../cubit/language_cubit.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import '../models/quiz_question.dart';

/// Quiz screen — three phases driven by [QuizCubit] state:
///   • idle      → intro + Start button
///   • inProgress → question card with 4 choices
///   • finished  → score + per-question review
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) {
            switch (state.phase) {
              case QuizPhase.idle:
                return _QuizIntro(onStart: () => _startQuiz(context));
              case QuizPhase.inProgress:
                return _QuizQuestionView(state: state);
              case QuizPhase.finished:
                return _QuizResults(
                  state: state,
                  onRetry: () => _startQuiz(context),
                );
            }
          },
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context) {
    final hadithState = context.read<HadithCubit>().state;
    if (hadithState is! HadithLoaded) return;
    final arabic = context.read<LanguageCubit>().state.isArabic;
    context.read<QuizCubit>().start(
          hadiths: hadithState.hadiths,
          arabic: arabic,
        );
  }
}

class _QuizIntro extends StatelessWidget {
  final VoidCallback onStart;
  const _QuizIntro({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined,
                size: 96, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              l10n.quizTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.quizIntro,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.quizStart),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestionView extends StatelessWidget {
  final QuizState state;
  const _QuizQuestionView({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final progress = (state.currentIndex + 1) / state.questions.length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar + counter
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.primary
                        .withValues(alpha: 0.15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.quizProgress(
                    state.currentIndex + 1, state.questions.length),
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question card
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        question.prompt,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < question.choices.length; i++) ...[
                    _ChoiceButton(
                      label: question.choices[i],
                      onTap: () => _select(context, i),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, int choice) {
    context.read<QuizCubit>().answer(choice);
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ChoiceButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.radio_button_unchecked,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizResults extends StatelessWidget {
  final QuizState state;
  final VoidCallback onRetry;
  const _QuizResults({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final correct = state.correctCount;
    final total = state.questions.length;
    final pct = total == 0 ? 0 : (correct / total * 100).round();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Icon(
            pct >= 80
                ? Icons.emoji_events
                : (pct >= 50 ? Icons.thumb_up_outlined : Icons.refresh),
            size: 88,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.quizResultScore(correct, total),
            style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _verdict(pct, l10n),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: state.questions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final q = state.questions[i];
                final picked = i < state.answers.length ? state.answers[i] : -1;
                final isCorrect = picked == q.correctIndex;
                return _ReviewTile(
                  question: q,
                  pickedIndex: picked,
                  isCorrect: isCorrect,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.quizRetry),
                  onPressed: onRetry,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(l10n.done),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _verdict(int pct, AppLocalizations l10n) {
    if (pct >= 80) return l10n.quizVerdictExcellent;
    if (pct >= 50) return l10n.quizVerdictGood;
    return l10n.quizVerdictKeepLearning;
  }
}

class _ReviewTile extends StatelessWidget {
  final QuizQuestion question;
  final int pickedIndex;
  final bool isCorrect;
  const _ReviewTile({
    required this.question,
    required this.pickedIndex,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? Colors.green : Colors.redAccent;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                  color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.quizReviewHadithRef(question.sourceHadithIndex),
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 6),
            Text(
              '${l10n.quizReviewCorrect}: ${question.correctAnswer}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
