import 'package:equatable/equatable.dart';

/// State for reading streaks (consecutive days of at-least-one hadith read).
///
/// We deliberately avoid heavy gamification language ("level", "points",
/// "achievement unlocked"). The streak is presented as gentle encouragement
/// toward istiqamah (consistency), aligned with the app's da'wah purpose.
class ReadingStreaksState extends Equatable {
  /// Current consecutive-day streak. Zero if no reading recorded yet, or if
  /// the user has missed at least one full day since last read.
  final int current;

  /// Longest streak ever achieved on this device (across resets / reinstalls,
  /// stored in SharedPreferences so it survives between launches).
  final int longest;

  /// The last calendar date (local timezone) on which any hadith was read.
  /// `null` means no hadith has ever been recorded.
  final DateTime? lastDate;

  /// Whether the streak data is still loading from disk.
  final bool isLoading;

  const ReadingStreaksState({
    this.current = 0,
    this.longest = 0,
    this.lastDate,
    this.isLoading = false,
  });

  ReadingStreaksState copyWith({
    int? current,
    int? longest,
    DateTime? lastDate,
    bool? isLoading,
    bool clearLastDate = false,
  }) {
    return ReadingStreaksState(
      current: current ?? this.current,
      longest: longest ?? this.longest,
      lastDate: clearLastDate ? null : (lastDate ?? this.lastDate),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Whether a hadith was read on [day] (time-of-day ignored).
  ///
  /// Derived rather than stored: a streak of [current] days ending on
  /// [lastDate] covers exactly `[lastDate - (current - 1), lastDate]`, which
  /// is enough to draw a recent-days view without persisting a per-day log.
  bool wasReadOn(DateTime day) {
    final last = lastDate;
    if (last == null || current <= 0) return false;
    final target = DateTime(day.year, day.month, day.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    final firstDay = lastDay.subtract(Duration(days: current - 1));
    return !target.isBefore(firstDay) && !target.isAfter(lastDay);
  }

  @override
  List<Object?> get props => [current, longest, lastDate, isLoading];
}
