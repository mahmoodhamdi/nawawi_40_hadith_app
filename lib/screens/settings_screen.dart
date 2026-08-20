import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants.dart';
import '../core/l10n/app_localizations.dart';
import '../cubit/language_cubit.dart';
import '../cubit/language_state.dart';
import '../cubit/reading_stats_cubit.dart';
import '../cubit/reading_streaks_cubit.dart';
import '../cubit/reading_streaks_state.dart';
import '../cubit/reminder_cubit.dart';
import '../cubit/reminder_state.dart';
import '../services/feedback_service.dart';
import '../widgets/app_dialog.dart';
import 'quiz_screen.dart';

/// Settings screen for managing app preferences.
///
/// Laid out as a dense list of rows rather than one tall card per setting:
/// the card-per-feature version pushed a five-item screen past two full
/// scrolls, with a 250px block just to choose between two languages.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionHeader(l10n.sectionPreferences),
          _Group(
            children: [
              _buildLanguageTile(context, theme, l10n),
              ..._buildReminderTiles(context, theme, l10n),
            ],
          ),

          _SectionHeader(l10n.sectionJourney),
          _Group(
            children: [
              _buildStreakTile(context, theme, l10n),
              _buildQuizTile(context, theme, l10n),
            ],
          ),

          _SectionHeader(l10n.sectionContact),
          _Group(children: [_buildFeedbackTile(context, theme, l10n)]),
        ],
      ),
    );
  }

  // ─── Language ───────────────────────────────────────────────────────

  Widget _buildLanguageTile(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return _Tile(
          icon: Icons.language,
          title: l10n.languageLabel,
          // The two choices sit on the row itself instead of as two large
          // bordered blocks stacked underneath it.
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageChip(
                label: l10n.arabic,
                selected: state.isArabic,
                onTap: () => context.read<LanguageCubit>().changeLanguage(
                  AppLanguage.arabic,
                ),
              ),
              const SizedBox(width: 6),
              _LanguageChip(
                label: 'English',
                selected: state.isEnglish,
                onTap: () => context.read<LanguageCubit>().changeLanguage(
                  AppLanguage.english,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Daily reminder ─────────────────────────────────────────────────

  List<Widget> _buildReminderTiles(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return [
      BlocBuilder<ReminderCubit, ReminderState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const _Tile(
              icon: Icons.notifications_active,
              title: '',
              trailing: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Tile(
                icon: Icons.notifications_active,
                title: l10n.dailyReminder,
                subtitle: l10n.dailyReminderDescription,
                trailing: Switch(
                  value: state.isEnabled,
                  onChanged: (_) => _toggleReminder(context),
                ),
                onTap: () => _toggleReminder(context),
              ),
              // Time and the permission warning only exist while the reminder
              // is on, so they cost nothing when it is off.
              if (state.isEnabled) ...[
                const _TileDivider(),
                _Tile(
                  icon: Icons.access_time,
                  title: l10n.reminderTime,
                  onTap: () => _selectTime(context, state.reminderTime, l10n),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.formattedTimeArabic,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_left,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!state.hasPermission) ...[
                  const _TileDivider(),
                  _Tile(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                    title: l10n.permissionRequired,
                    onTap: () => _requestPermissions(context),
                    trailing: TextButton(
                      onPressed: () => _requestPermissions(context),
                      child: Text(l10n.allowPermission),
                    ),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    ];
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

  // ─── Reading streak ─────────────────────────────────────────────────

  Widget _buildStreakTile(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<ReadingStreaksCubit, ReadingStreaksState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const _Tile(
            icon: Icons.local_fire_department,
            title: '',
            trailing: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final scheme = theme.colorScheme;
        final active = state.current > 0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The count reads inline beside the title rather than inside a
              // 148px ring that pushed everything else off the screen.
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 22,
                    color: active
                        ? scheme.secondary
                        : scheme.onSurface.withValues(alpha: 0.35),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.streakCurrentLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    l10n.streakDays(state.current),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: active
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (state.longest > 0)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.streakReset,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                      onPressed: () => _confirmStreakReset(context, l10n),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _StreakWeekStrip(state: state),
              const SizedBox(height: 10),
              Text(
                active
                    ? '${l10n.streakLongestLabel}: ${l10n.streakDays(state.longest)}'
                    : l10n.streakEncouragement,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmStreakReset(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      icon: Icons.refresh,
      title: l10n.streakReset,
      message: l10n.streakResetBody,
      confirmLabel: l10n.yes,
      destructive: true,
    );
    if (confirmed && context.mounted) {
      await context.read<ReadingStreaksCubit>().reset();
    }
  }

  // ─── Quiz ───────────────────────────────────────────────────────────

  Widget _buildQuizTile(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return _Tile(
      icon: Icons.quiz_outlined,
      title: l10n.quizTitle,
      subtitle: l10n.quizIntro,
      trailing: const _Chevron(),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const QuizScreen())),
    );
  }

  // ─── Feedback ───────────────────────────────────────────────────────

  Widget _buildFeedbackTile(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return _Tile(
      icon: Icons.chat_outlined,
      title: l10n.sendFeedback,
      subtitle: l10n.feedbackIntro,
      trailing: const _Chevron(),
      onTap: () => _composeFeedback(context, l10n),
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
}

/// A card that holds a run of [_Tile]s, drawing the hairlines between them.
class _Group extends StatelessWidget {
  final List<Widget> children;

  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(const _TileDivider());
      rows.add(children[i]);
    }
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

/// One settings row: icon, title, optional subtitle, optional trailing
/// control. Deliberately tighter than [ListTile], which reserves more
/// vertical space than these rows need.
class _Tile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 50,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_left,
      size: 20,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
    );
  }
}

/// One of the two language options, sized to sit on the row itself.
class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// The last seven calendar days, filled where a hadith was read.
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final read = state.wasReadOn(day);
        final isToday = day == today;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
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
                  ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
                  : null,
            ),
            const SizedBox(height: 5),
            Text(
              l10n.weekdayInitial(day.weekday),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: isToday ? 0.9 : 0.45),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Label that introduces a group of settings rows.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, top: 22, bottom: 8),
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
