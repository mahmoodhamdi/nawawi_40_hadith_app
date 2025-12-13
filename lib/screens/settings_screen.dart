import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/l10n/app_localizations.dart';
import '../cubit/language_cubit.dart';
import '../cubit/language_state.dart';
import '../cubit/reading_stats_cubit.dart';
import '../cubit/reminder_cubit.dart';
import '../cubit/reminder_state.dart';

/// Settings screen for managing app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLanguageSection(context, theme, l10n),
          const SizedBox(height: 16),
          _buildReminderSection(context, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, ThemeData theme, AppLocalizations l10n) {
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
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSection(BuildContext context, ThemeData theme, AppLocalizations l10n) {
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
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                    state.isEnabled ? l10n.reminderEnabled : l10n.reminderDisabled,
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
                  activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
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

  void _selectTime(BuildContext context, TimeOfDay currentTime, AppLocalizations l10n) async {
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
                hourMinuteTextColor: theme.colorScheme.primary,
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
