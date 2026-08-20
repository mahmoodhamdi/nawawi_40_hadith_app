import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants.dart';
import '../core/l10n/app_localizations.dart';
import '../cubit/language_cubit.dart';
import '../cubit/language_state.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';
import '../cubit/reading_stats_cubit.dart';
import '../cubit/reading_streaks_cubit.dart';
import '../cubit/reading_streaks_state.dart';
import '../cubit/reminder_cubit.dart';
import '../cubit/reminder_state.dart';
import '../services/feedback_service.dart';
import 'quiz_screen.dart';

/// Settings screen for managing app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      // Grouped under labelled headings; a flat list of equally-weighted
      // cards gave the eye nothing to anchor on.
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionHeader(l10n.sectionPreferences),
          _buildLanguageSection(context, theme, l10n),
          const SizedBox(height: 12),
          _buildReminderSection(context, theme, l10n),

          _SectionHeader(l10n.sectionJourney),
          _buildStreaksSection(context, theme, l10n),
          const SizedBox(height: 12),
          _buildNotesSection(context, theme, l10n),
          const SizedBox(height: 12),
          _buildQuizSection(context, theme, l10n),

          _SectionHeader(l10n.sectionContact),
          _buildFeedbackSection(context, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildQuizSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.quizTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.quizIntro,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.quizStart),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const QuizScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Reading Streaks ────────────────────────────────────────────────

  Widget _buildStreaksSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<ReadingStreaksCubit, ReadingStreaksState>(
      builder: (context, state) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.streakCurrentLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  Center(child: _StreakHero(count: state.current)),
                  const SizedBox(height: 20),
                  _StreakWeekStrip(state: state),
                  if (state.current == 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.streakEncouragement,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (state.longest > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.55,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.streakLongestLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          l10n.streakDays(state.longest),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(l10n.streakReset),
                        onPressed: () => _confirmStreakReset(context, l10n),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmStreakReset(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmAction),
        content: Text(l10n.streakReset),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ReadingStreaksCubit>().reset();
    }
  }

  // ─── Notes ──────────────────────────────────────────────────────────

  Widget _buildNotesSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final count = state.notes.length;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.notes,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (count > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.notesCount(count),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 24),
                if (count == 0)
                  // Without this the card was a bare title with no content and
                  // nothing to tap — it read as broken rather than empty.
                  Text(
                    l10n.notesEmptyHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  )
                else
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(l10n.clearAllNotes),
                      onPressed: () => _confirmClearNotes(context, l10n),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmClearNotes(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmAction),
        content: Text(l10n.clearAllNotes),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<NotesCubit>().clearAll();
    }
  }

  // ─── Feedback ───────────────────────────────────────────────────────

  Widget _buildFeedbackSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.feedback_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.sendFeedback,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.feedbackIntro,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send_outlined),
                label: Text(l10n.sendFeedback),
                onPressed: () => _composeFeedback(context, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens WhatsApp addressed to the maintainer, with a short header already
  /// written. There is no in-app compose dialog on purpose: the user writes
  /// the note where they are going to send it from.
  Future<void> _composeFeedback(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final locale = context.read<LanguageCubit>().state.language.code;
    final messenger = ScaffoldMessenger.of(context);

    final channel = await FeedbackService.sendFeedback(
      message: FeedbackService.buildWhatsappPrefill(
        appVersion: AppInfo.appVersion,
        locale: locale,
        noteLabel: l10n.feedbackNoteLabel,
      ),
      appVersion: AppInfo.appVersion,
    );

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          channel == FeedbackChannel.whatsapp
              ? l10n.feedbackOpeningWhatsapp
              : l10n.feedbackWhatsappUnavailable,
        ),
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.languageLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Language options
                _buildLanguageOption(
                  context: context,
                  theme: theme,
                  language: AppLanguage.arabic,
                  isSelected: state.isArabic,
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  context: context,
                  theme: theme,
                  language: AppLanguage.english,
                  isSelected: state.isEnglish,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required ThemeData theme,
    required AppLanguage language,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => context.read<LanguageCubit>().changeLanguage(language),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language.displayName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<ReminderCubit, ReminderState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dailyReminder,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.dailyReminderDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Toggle switch
                SwitchListTile(
                  title: Text(
                    state.isEnabled
                        ? l10n.reminderEnabled
                        : l10n.reminderDisabled,
                    style: theme.textTheme.bodyLarge,
                  ),
                  subtitle: state.isEnabled
                      ? Text(
                          '${l10n.reminderTime}: ${state.formattedTimeArabic}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                  value: state.isEnabled,
                  onChanged: state.isLoading
                      ? null
                      : (value) => _toggleReminder(context),
                  activeTrackColor: theme.colorScheme.primary.withValues(
                    alpha: 0.5,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),

                // Time picker (only shown when enabled)
                if (state.isEnabled) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.access_time,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(l10n.selectTime),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.formattedTimeArabic,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => _selectTime(context, state.reminderTime, l10n),
                  ),
                ],

                // Permission warning
                if (!state.hasPermission && state.isEnabled) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.permissionRequired,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _requestPermissions(context),
                          child: Text(l10n.allowPermission),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleReminder(BuildContext context) {
    final reminderCubit = context.read<ReminderCubit>();
    final statsCubit = context.read<ReadingStatsCubit>();
    final statsState = statsCubit.state;

    // Get the next unread hadith number
    int? nextHadith;
    if (!statsState.isLoading) {
      final unread = statsCubit.getUnreadHadiths(statsState.totalHadiths);
      if (unread.isNotEmpty) {
        nextHadith = unread.first;
      }
    }

    reminderCubit.toggleReminder(nextHadithNumber: nextHadith);
  }

  void _selectTime(
    BuildContext context,
    TimeOfDay currentTime,
    AppLocalizations l10n,
  ) async {
    final theme = Theme.of(context);
    final languageState = context.read<LanguageCubit>().state;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: l10n.selectTime,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
      builder: (context, child) {
        return Directionality(
          textDirection: languageState.textDirection,
          child: Theme(
            data: theme.copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: theme.scaffoldBackgroundColor,
                // The selected hour/minute field is *filled* with the
                // primary colour, so its digits have to be onPrimary.
                // Setting only the text colour left primary-on-primary —
                // the selected field rendered as a blank coloured block.
                hourMinuteColor: WidgetStateColor.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.08),
                ),
                hourMinuteTextColor: WidgetStateColor.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                ),
                dayPeriodTextColor: theme.colorScheme.primary,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (selectedTime != null && context.mounted) {
      final reminderCubit = context.read<ReminderCubit>();
      final statsCubit = context.read<ReadingStatsCubit>();
      final statsState = statsCubit.state;

      // Get the next unread hadith number
      int? nextHadith;
      if (!statsState.isLoading) {
        final unread = statsCubit.getUnreadHadiths(statsState.totalHadiths);
        if (unread.isNotEmpty) {
          nextHadith = unread.first;
        }
      }

      reminderCubit.setReminderTime(selectedTime, nextHadithNumber: nextHadith);
    }
  }

  void _requestPermissions(BuildContext context) {
    context.read<ReminderCubit>().requestPermissions();
  }
}

/// The streak count as the centrepiece of the card: a soft ring with the
/// number inside and a flame resting on its edge. Two plain label/value rows
/// carried the same information but gave the eye nothing to land on.
class _StreakHero extends StatelessWidget {
  final int count;

  const _StreakHero({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final scheme = theme.colorScheme;
    final active = count > 0;
    final ring = active
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.25);

    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  scheme.primary.withValues(alpha: active ? 0.14 : 0.05),
                  scheme.primary.withValues(alpha: 0.02),
                ],
              ),
              border: Border.all(color: ring, width: active ? 3 : 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$count',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: active ? scheme.primary : scheme.onSurface,
                    height: 1.1,
                  ),
                ),
                Text(
                  count == 1 ? l10n.streakDayUnit : l10n.streakDaysUnit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (active)
            PositionedDirectional(
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surface,
                  border: Border.all(color: scheme.primary, width: 2),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  size: 20,
                  color: scheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The last seven calendar days, filled where a hadith was read.
///
/// Derived rather than stored: a streak of [current] days ending on
/// [lastDate] covers exactly the days in
/// `[lastDate - (current - 1), lastDate]`, so no extra persistence is needed
/// to draw this honestly.
class _StreakWeekStrip extends StatelessWidget {
  final ReadingStreaksState state;

  const _StreakWeekStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return Column(
      children: [
        Text(
          l10n.streakLastWeek,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((day) {
            final read = state.wasReadOn(day);
            final isToday = day == today;
            return Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: read
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: 0.06),
                    border: isToday
                        ? Border.all(color: scheme.secondary, width: 2)
                        : null,
                  ),
                  child: read
                      ? Icon(Icons.check, size: 17, color: scheme.onPrimary)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.weekdayInitial(day.weekday),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(
                      alpha: isToday ? 0.9 : 0.5,
                    ),
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Label that introduces a group of settings cards.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, top: 24, bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// One `label — value` line inside the About card.
