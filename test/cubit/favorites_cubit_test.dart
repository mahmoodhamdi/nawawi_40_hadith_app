import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/core/constants.dart';
import 'package:hadith_nawawi_audio/cubit/favorites_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/favorites_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesState', () {
    test('default state has empty favorites and loading true', () {
      const state = FavoritesState();

      expect(state.favoriteIndices, isEmpty);
      expect(state.isLoading, false);
      expect(state.count, 0);
    });

    test('can create state with favorites', () {
      const state = FavoritesState(
        favoriteIndices: {1, 5, 10},
        isLoading: false,
      );

      expect(state.favoriteIndices, {1, 5, 10});
      expect(state.count, 3);
      expect(state.isLoading, false);
    });

    test('isFavorite returns true for favorites', () {
      const state = FavoritesState(favoriteIndices: {1, 5, 10});

      expect(state.isFavorite(1), true);
      expect(state.isFavorite(5), true);
      expect(state.isFavorite(10), true);
      expect(state.isFavorite(2), false);
      expect(state.isFavorite(99), false);
    });

    test('copyWith updates favoriteIndices', () {
      const state = FavoritesState(favoriteIndices: {1, 2});
      final newState = state.copyWith(favoriteIndices: {3, 4, 5});

      expect(newState.favoriteIndices, {3, 4, 5});
      expect(newState.count, 3);
    });

    test('copyWith updates isLoading', () {
      const state = FavoritesState(isLoading: false);
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, true);
    });

    test('copyWith preserves values when not specified', () {
      const state = FavoritesState(
        favoriteIndices: {1, 2, 3},
        isLoading: true,
      );
      final newState = state.copyWith();

      expect(newState.favoriteIndices, {1, 2, 3});
      expect(newState.isLoading, true);
    });

    test('props contains favoriteIndices and isLoading', () {
      const state = FavoritesState(
        favoriteIndices: {1, 2},
        isLoading: true,
      );

      expect(state.props.length, 2);
      expect(state.props[0], {1, 2});
      expect(state.props[1], true);
    });

    test('states with same values are equal', () {
      const state1 = FavoritesState(
        favoriteIndices: {1, 2, 3},
        isLoading: false,
      );
      const state2 = FavoritesState(
        favoriteIndices: {1, 2, 3},
        isLoading: false,
      );

      expect(state1, equals(state2));
    });

    test('states with different favorites are not equal', () {
      const state1 = FavoritesState(favoriteIndices: {1, 2, 3});
      const state2 = FavoritesState(favoriteIndices: {4, 5, 6});

      expect(state1, isNot(equals(state2)));
    });

    test('states with different isLoading are not equal', () {
      const state1 = FavoritesState(isLoading: true);
      const state2 = FavoritesState(isLoading: false);

      expect(state1, isNot(equals(state2)));
    });

    test('count returns correct number of favorites', () {
      expect(const FavoritesState().count, 0);
      expect(const FavoritesState(favoriteIndices: {1}).count, 1);
      expect(const FavoritesState(favoriteIndices: {1, 2, 3, 4, 5}).count, 5);
    });
  });

  group('FavoritesCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state starts loading', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = FavoritesCubit();

      // Wait for loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.favoriteIndices, isEmpty);
      expect(cubit.state.isLoading, false);

      await cubit.close();
    });

    test('loads saved favorites from preferences', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.favorites: ['1', '5', '10'],
      });

      final cubit = FavoritesCubit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.favoriteIndices, {1, 5, 10});
      expect(cubit.state.isLoading, false);

      await cubit.close();
    });

    test('toggleFavorite adds hadith to favorites', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.toggleFavorite(5);

      expect(cubit.state.isFavorite(5), true);
      expect(cubit.state.count, 1);

      await cubit.close();
    });

    test('toggleFavorite removes hadith from favorites', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.favorites: ['5'],
      });
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.isFavorite(5), true);

      await cubit.toggleFavorite(5);

      expect(cubit.state.isFavorite(5), false);
      expect(cubit.state.count, 0);

      await cubit.close();
    });

    test('addFavorite adds hadith to favorites', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addFavorite(10);

      expect(cubit.state.isFavorite(10), true);
      expect(cubit.state.count, 1);

      await cubit.close();
    });

    test('addFavorite does not duplicate existing favorite', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.favorites: ['10'],
      });
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addFavorite(10);

      expect(cubit.state.count, 1);

      await cubit.close();
    });

    test('removeFavorite removes hadith from favorites', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.favorites: ['5', '10', '15'],
      });
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.removeFavorite(10);

      expect(cubit.state.isFavorite(10), false);
      expect(cubit.state.isFavorite(5), true);
      expect(cubit.state.isFavorite(15), true);
      expect(cubit.state.count, 2);

      await cubit.close();
    });

    test('removeFavorite does nothing for non-favorite', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.favorites: ['5'],
      });
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.removeFavorite(10);

      expect(cubit.state.count, 1);
      expect(cubit.state.isFavorite(5), true);

      await cubit.close();
    });

    test('clearAllFavorites removes all favorites', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.favorites: ['1', '2', '3', '4', '5'],
      });
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.count, 5);

      await cubit.clearAllFavorites();

      expect(cubit.state.count, 0);
      expect(cubit.state.favoriteIndices, isEmpty);

      await cubit.close();
    });

    test('isFavorite method works correctly', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.favorites: ['5', '10'],
      });
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.isFavorite(5), true);
      expect(cubit.isFavorite(10), true);
      expect(cubit.isFavorite(1), false);
      expect(cubit.isFavorite(15), false);

      await cubit.close();
    });

    test('sortedFavorites returns sorted list', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.favorites: ['10', '5', '1', '15', '3'],
      });
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.sortedFavorites, [1, 3, 5, 10, 15]);

      await cubit.close();
    });

    test('toggleFavorite ignores invalid index below minimum', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.toggleFavorite(0);
      await cubit.toggleFavorite(-1);

      expect(cubit.state.count, 0);

      await cubit.close();
    });

    test('toggleFavorite ignores invalid index above maximum', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.toggleFavorite(101);
      await cubit.toggleFavorite(999);

      expect(cubit.state.count, 0);

      await cubit.close();
    });

    test('favorites are persisted to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addFavorite(5);
      await cubit.addFavorite(10);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(PreferenceKeys.favorites);

      expect(saved, isNotNull);
      expect(saved!.contains('5'), true);
      expect(saved.contains('10'), true);

      await cubit.close();
    });

    test('loadFavorites filters out invalid indices', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.favorites: ['5', '0', '-1', '101', '10', 'invalid'],
      });
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      // Only valid indices (5 and 10) should be loaded
      expect(cubit.state.favoriteIndices, {5, 10});
      expect(cubit.state.count, 2);

      await cubit.close();
    });

    test('multiple operations work correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = FavoritesCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      await cubit.addFavorite(1);
      await cubit.addFavorite(2);
      await cubit.addFavorite(3);
      expect(cubit.state.count, 3);

      await cubit.removeFavorite(2);
      expect(cubit.state.count, 2);
      expect(cubit.state.isFavorite(2), false);

      await cubit.toggleFavorite(3);
      expect(cubit.state.count, 1);
      expect(cubit.state.isFavorite(3), false);

      await cubit.toggleFavorite(5);
      expect(cubit.state.count, 2);
      expect(cubit.state.isFavorite(5), true);

      expect(cubit.sortedFavorites, [1, 5]);

      await cubit.close();
    });
  });
}
