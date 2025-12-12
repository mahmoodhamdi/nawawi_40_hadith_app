import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'favorites_state.dart';

/// Cubit for managing favorite hadiths
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState(isLoading: true)) {
    loadFavorites();
  }

  /// Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(PreferenceKeys.favorites);

      if (favoritesJson != null) {
        final favorites = favoritesJson
            .map((s) => int.tryParse(s))
            .where((i) => i != null && _isValidIndex(i))
            .cast<int>()
            .toSet();

        emit(state.copyWith(
          favoriteIndices: favorites,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          favoriteIndices: {},
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Toggle favorite status for a hadith
  Future<void> toggleFavorite(int hadithIndex) async {
    if (!_isValidIndex(hadithIndex)) return;

    final newFavorites = Set<int>.from(state.favoriteIndices);

    if (newFavorites.contains(hadithIndex)) {
      newFavorites.remove(hadithIndex);
    } else {
      newFavorites.add(hadithIndex);
    }

    emit(state.copyWith(favoriteIndices: newFavorites));
    await _saveFavorites(newFavorites);
  }

  /// Add a hadith to favorites
  Future<void> addFavorite(int hadithIndex) async {
    if (!_isValidIndex(hadithIndex)) return;
    if (state.favoriteIndices.contains(hadithIndex)) return;

    final newFavorites = Set<int>.from(state.favoriteIndices)..add(hadithIndex);
    emit(state.copyWith(favoriteIndices: newFavorites));
    await _saveFavorites(newFavorites);
  }

  /// Remove a hadith from favorites
  Future<void> removeFavorite(int hadithIndex) async {
    if (!state.favoriteIndices.contains(hadithIndex)) return;

    final newFavorites = Set<int>.from(state.favoriteIndices)
      ..remove(hadithIndex);
    emit(state.copyWith(favoriteIndices: newFavorites));
    await _saveFavorites(newFavorites);
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    emit(state.copyWith(favoriteIndices: {}));
    await _saveFavorites({});
  }

  /// Check if a hadith is in favorites
  bool isFavorite(int hadithIndex) {
    return state.favoriteIndices.contains(hadithIndex);
  }

  /// Get sorted list of favorite indices
  List<int> get sortedFavorites {
    final list = state.favoriteIndices.toList();
    list.sort();
    return list;
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites(Set<int> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = favorites.map((i) => i.toString()).toList();
      await prefs.setStringList(PreferenceKeys.favorites, favoritesJson);
    } catch (e) {
      // Silently fail - favorites will be lost on restart
    }
  }

  /// Validate hadith index
  bool _isValidIndex(int index) {
    return index >= ValidationConstants.minHadithIndex &&
        index <= ValidationConstants.maxHadithIndex;
  }
}
