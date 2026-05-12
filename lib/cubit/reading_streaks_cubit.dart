import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'reading_streaks_state.dart';

/// Tracks consecutive-day reading streaks.
///
/// "Reading" is defined as the user opening any hadith details screen (which
/// already triggers `ReadingStatsCubit.markAsRead`). On every such event the
/// caller also invokes [recordRead]. The day boundary is the **local
/// calendar date** — not 24 hours from the last read — to match how the user
/// thinks about "a day of reading".
///
/// State transitions on [recordRead] (today = local calendar date):
///   - lastDate == null           → current = 1, longest = max(1, longest)
///   - lastDate == today          → no change (already counted)
///   - lastDate == today - 1 day  → current += 1, longest = max(...)
///   - lastDate < today - 1 day   → current = 1, longest unchanged
class ReadingStreaksCubit extends Cubit<ReadingStreaksState> {
  ReadingStreaksCubit() : super(const ReadingStreaksState(isLoading: true)) {
    loadStreaks();
  }

  /// Returns today's local calendar date with the time stripped (midnight).
  ///
  /// Marked `@visibleForTesting` so tests can override clock behavior by
  /// subclassing or by providing a fixed clock in their setUp.
  @visibleForTesting
  DateTime nowLocal() => DateTime.now();

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> loadStreaks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(PreferenceKeys.streakCurrent) ?? 0;
      final longest = prefs.getInt(PreferenceKeys.streakLongest) ?? 0;
      final lastStr = prefs.getString(PreferenceKeys.streakLastDate);
      DateTime? lastDate;
      if (lastStr != null) {
        try {
          lastDate = DateTime.parse(lastStr);
        } on FormatException {
          // Stored date is corrupted; drop it.
          await prefs.remove(PreferenceKeys.streakLastDate);
        }
      }

      // Recompute "current" if the user opens the app after a multi-day gap
      // without recording a read: their streak should already be considered
      // broken before they even tap a hadith.
      var effectiveCurrent = current;
      if (lastDate != null) {
        final today = _dateOnly(nowLocal());
        final last = _dateOnly(lastDate);
        final gap = today.difference(last).inDays;
        if (gap > 1) {
          effectiveCurrent = 0;
        }
      }

      emit(state.copyWith(
        current: effectiveCurrent,
        longest: longest,
        lastDate: lastDate,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Error loading reading streaks: $e');
      emit(const ReadingStreaksState(isLoading: false));
    }
  }

  /// Record that the user read a hadith today.
  ///
  /// Idempotent within the same calendar day — calling multiple times on
  /// the same date never inflates the streak.
  Future<void> recordRead() async {
    final today = _dateOnly(nowLocal());

    final last = state.lastDate;
    int newCurrent;

    if (last == null) {
      newCurrent = 1;
    } else {
      final lastDay = _dateOnly(last);
      final gap = today.difference(lastDay).inDays;
      if (gap == 0) {
        // Already recorded today.
        return;
      } else if (gap == 1) {
        newCurrent = state.current + 1;
      } else {
        // Gap > 1 day OR same-day after time-warp backwards (gap < 0).
        // In both cases, start a fresh streak.
        newCurrent = 1;
      }
    }

    final newLongest =
        newCurrent > state.longest ? newCurrent : state.longest;

    emit(state.copyWith(
      current: newCurrent,
      longest: newLongest,
      lastDate: today,
    ));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PreferenceKeys.streakCurrent, newCurrent);
    await prefs.setInt(PreferenceKeys.streakLongest, newLongest);
    await prefs.setString(
      PreferenceKeys.streakLastDate,
      today.toIso8601String(),
    );
  }

  /// Resets all streak data. Intended for a settings-screen action so the
  /// user can clear progress.
  Future<void> reset() async {
    emit(const ReadingStreaksState(isLoading: false));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferenceKeys.streakCurrent);
    await prefs.remove(PreferenceKeys.streakLongest);
    await prefs.remove(PreferenceKeys.streakLastDate);
  }
}
