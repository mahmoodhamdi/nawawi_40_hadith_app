import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/notification_service.dart';
import '../services/preferences_service.dart';
import 'reminder_state.dart';

/// Cubit for managing daily reminder settings
class ReminderCubit extends Cubit<ReminderState> {
  ReminderCubit() : super(const ReminderState()) {
    loadSettings();
  }

  /// Notification title in Arabic
  static const String _notificationTitle = 'حان وقت حديث اليوم';

  /// Notification body template
  static String _notificationBody(int hadithNumber) =>
      'الحديث رقم $hadithNumber من الأربعين النووية';

  /// Default notification body when no specific hadith
  static const String _defaultNotificationBody =
      'حان الوقت لقراءة حديث من الأربعين النووية';

  /// Loads reminder settings from preferences
  Future<void> loadSettings() async {
    try {
      final isEnabled = await PreferencesService.getReminderEnabled();
      final reminderTime = await PreferencesService.getReminderTime();
      final hasPermission = await NotificationService.hasPermissions();

      emit(state.copyWith(
        isEnabled: isEnabled,
        reminderTime: reminderTime,
        hasPermission: hasPermission,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Error loading reminder settings: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Toggles the reminder on/off
  Future<void> toggleReminder({int? nextHadithNumber}) async {
    if (state.isLoading) return;

    final newEnabled = !state.isEnabled;

    // If enabling, check permissions first
    if (newEnabled && !state.hasPermission) {
      final granted = await requestPermissions();
      if (!granted) {
        // Permission denied, cannot enable
        return;
      }
    }

    emit(state.copyWith(isLoading: true));

    try {
      if (newEnabled) {
        // Schedule the notification
        await NotificationService.scheduleDailyReminder(
          time: state.reminderTime,
          title: _notificationTitle,
          body: nextHadithNumber != null
              ? _notificationBody(nextHadithNumber)
              : _defaultNotificationBody,
          payload: nextHadithNumber?.toString(),
        );
      } else {
        // Cancel the notification
        await NotificationService.cancelReminder();
      }

      // Save the preference
      await PreferencesService.saveReminderEnabled(newEnabled);

      emit(state.copyWith(
        isEnabled: newEnabled,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Error toggling reminder: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Sets a new reminder time
  Future<void> setReminderTime(TimeOfDay time, {int? nextHadithNumber}) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      // Save the new time
      await PreferencesService.saveReminderTime(time);

      // If reminder is enabled, reschedule with new time
      if (state.isEnabled) {
        await NotificationService.scheduleDailyReminder(
          time: time,
          title: _notificationTitle,
          body: nextHadithNumber != null
              ? _notificationBody(nextHadithNumber)
              : _defaultNotificationBody,
          payload: nextHadithNumber?.toString(),
        );
      }

      emit(state.copyWith(
        reminderTime: time,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Error setting reminder time: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Requests notification permissions
  ///
  /// Returns true if permissions are granted
  Future<bool> requestPermissions() async {
    try {
      final granted = await NotificationService.requestPermissions();
      emit(state.copyWith(hasPermission: granted));
      return granted;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Refreshes permission status
  Future<void> refreshPermissionStatus() async {
    final hasPermission = await NotificationService.hasPermissions();
    if (hasPermission != state.hasPermission) {
      emit(state.copyWith(hasPermission: hasPermission));
    }
  }

  /// Updates the notification content (call when next hadith changes)
  Future<void> updateNotificationContent(int nextHadithNumber) async {
    if (!state.isEnabled) return;

    try {
      await NotificationService.scheduleDailyReminder(
        time: state.reminderTime,
        title: _notificationTitle,
        body: _notificationBody(nextHadithNumber),
        payload: nextHadithNumber.toString(),
      );
    } catch (e) {
      debugPrint('Error updating notification content: $e');
    }
  }
}
