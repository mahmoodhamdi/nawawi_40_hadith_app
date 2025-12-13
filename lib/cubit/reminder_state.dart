import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State for the reminder cubit
class ReminderState extends Equatable {
  /// Whether the daily reminder is enabled
  final bool isEnabled;

  /// The time of day for the reminder
  final TimeOfDay reminderTime;

  /// Whether the state is currently loading
  final bool isLoading;

  /// Whether notification permissions are granted
  final bool hasPermission;

  /// Default reminder time (8:00 AM)
  static const TimeOfDay defaultTime = TimeOfDay(hour: 8, minute: 0);

  const ReminderState({
    this.isEnabled = false,
    this.reminderTime = defaultTime,
    this.isLoading = true,
    this.hasPermission = false,
  });

  /// Create a copy with updated values
  ReminderState copyWith({
    bool? isEnabled,
    TimeOfDay? reminderTime,
    bool? isLoading,
    bool? hasPermission,
  }) {
    return ReminderState(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }

  /// Format the reminder time as a string (HH:MM)
  String get formattedTime {
    final hour = reminderTime.hour.toString().padLeft(2, '0');
    final minute = reminderTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format the reminder time in Arabic (e.g., "8:00 صباحاً")
  String get formattedTimeArabic {
    final hour = reminderTime.hourOfPeriod;
    final minute = reminderTime.minute.toString().padLeft(2, '0');
    final period = reminderTime.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    return '$hour:$minute $period';
  }

  @override
  List<Object?> get props => [isEnabled, reminderTime.hour, reminderTime.minute, isLoading, hasPermission];
}
