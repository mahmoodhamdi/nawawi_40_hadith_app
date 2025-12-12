import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'reading_stats_state.dart';

/// Cubit for managing reading statistics
class ReadingStatsCubit extends Cubit<ReadingStatsState> {
  ReadingStatsCubit() : super(const ReadingStatsState(isLoading: true)) {
    loadStats();
  }

  /// Loads reading stats from SharedPreferences
  Future<void> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readList = prefs.getStringList(PreferenceKeys.readHadiths) ?? [];

      // Parse and validate indices
      final validIndices = <int>{};
      for (final indexStr in readList) {
        final index = int.tryParse(indexStr);
        if (index != null &&
            index >= ValidationConstants.minHadithIndex &&
            index <= ValidationConstants.maxHadithIndex) {
          validIndices.add(index);
        }
      }

      emit(state.copyWith(
        readHadithIndices: validIndices,
        isLoading: false,
      ));
    } catch (e) {
      // On error, emit empty state
      emit(state.copyWith(
        readHadithIndices: {},
        isLoading: false,
      ));
    }
  }

  /// Marks a hadith as read
  Future<void> markAsRead(int hadithIndex) async {
    // Validate index
    if (hadithIndex < ValidationConstants.minHadithIndex ||
        hadithIndex > ValidationConstants.maxHadithIndex) {
      return;
    }

    // Already read
    if (state.isRead(hadithIndex)) {
      return;
    }

    final newIndices = Set<int>.from(state.readHadithIndices)..add(hadithIndex);
    emit(state.copyWith(readHadithIndices: newIndices));

    await _saveToPreferences(newIndices);
  }

  /// Marks a hadith as unread
  Future<void> markAsUnread(int hadithIndex) async {
    if (!state.isRead(hadithIndex)) {
      return;
    }

    final newIndices = Set<int>.from(state.readHadithIndices)
      ..remove(hadithIndex);
    emit(state.copyWith(readHadithIndices: newIndices));

    await _saveToPreferences(newIndices);
  }

  /// Toggles the read status of a hadith
  Future<void> toggleReadStatus(int hadithIndex) async {
    if (state.isRead(hadithIndex)) {
      await markAsUnread(hadithIndex);
    } else {
      await markAsRead(hadithIndex);
    }
  }

  /// Checks if a hadith has been read
  bool isRead(int hadithIndex) => state.isRead(hadithIndex);

  /// Resets all reading progress
  Future<void> resetProgress() async {
    emit(state.copyWith(readHadithIndices: {}));

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferenceKeys.readHadiths);
  }

  /// Marks all hadiths as read
  Future<void> markAllAsRead(int totalCount) async {
    final allIndices = <int>{};
    for (int i = 1; i <= totalCount; i++) {
      allIndices.add(i);
    }

    emit(state.copyWith(readHadithIndices: allIndices));
    await _saveToPreferences(allIndices);
  }

  /// Gets a sorted list of read hadith indices
  List<int> get sortedReadHadiths {
    final list = state.readHadithIndices.toList()..sort();
    return list;
  }

  /// Gets a sorted list of unread hadith indices
  List<int> getUnreadHadiths(int totalCount) {
    final unread = <int>[];
    for (int i = 1; i <= totalCount; i++) {
      if (!state.isRead(i)) {
        unread.add(i);
      }
    }
    return unread;
  }

  /// Updates the total hadith count
  void setTotalHadiths(int count) {
    if (count > 0 && count != state.totalHadiths) {
      emit(state.copyWith(totalHadiths: count));
    }
  }

  /// Saves indices to SharedPreferences
  Future<void> _saveToPreferences(Set<int> indices) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = indices.map((i) => i.toString()).toList();
    await prefs.setStringList(PreferenceKeys.readHadiths, stringList);
  }
}
