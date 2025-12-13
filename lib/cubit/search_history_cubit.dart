import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'search_history_state.dart';

/// Cubit for managing search history
class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  SearchHistoryCubit() : super(const SearchHistoryState(isLoading: true)) {
    loadHistory();
  }

  /// Load search history from SharedPreferences
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(PreferenceKeys.searchHistory) ?? [];

      emit(state.copyWith(
        history: history,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Error loading search history: $e');
      emit(state.copyWith(
        history: [],
        isLoading: false,
      ));
    }
  }

  /// Add a search query to history
  ///
  /// If the query already exists, it will be moved to the top.
  /// History is limited to [SearchConstants.maxHistoryItems] items.
  Future<void> addSearchQuery(String query) async {
    final trimmedQuery = query.trim();

    // Ignore empty or too short queries
    if (trimmedQuery.length < SearchConstants.minQueryLengthForHistory) {
      return;
    }

    // Create new history list
    final newHistory = List<String>.from(state.history);

    // Remove if already exists (will be re-added at top)
    newHistory.remove(trimmedQuery);

    // Add to the beginning (most recent first)
    newHistory.insert(0, trimmedQuery);

    // Limit to max items
    if (newHistory.length > SearchConstants.maxHistoryItems) {
      newHistory.removeRange(
        SearchConstants.maxHistoryItems,
        newHistory.length,
      );
    }

    emit(state.copyWith(history: newHistory));
    await _saveHistory(newHistory);
  }

  /// Remove a specific query from history
  Future<void> removeQuery(String query) async {
    if (!state.history.contains(query)) return;

    final newHistory = List<String>.from(state.history)..remove(query);
    emit(state.copyWith(history: newHistory));
    await _saveHistory(newHistory);
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    emit(state.copyWith(history: []));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(PreferenceKeys.searchHistory);
    } catch (e) {
      debugPrint('Error clearing search history: $e');
    }
  }

  /// Check if a query exists in history
  bool hasQuery(String query) => state.history.contains(query);

  /// Save history to SharedPreferences
  Future<void> _saveHistory(List<String> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(PreferenceKeys.searchHistory, history);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }
}
