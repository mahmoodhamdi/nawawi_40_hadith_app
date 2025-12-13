import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/core/constants.dart';
import 'package:hadith_nawawi_audio/cubit/search_history_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/search_history_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SearchHistoryState', () {
    test('default state has empty history and loading false', () {
      const state = SearchHistoryState();

      expect(state.history, isEmpty);
      expect(state.isLoading, false);
      expect(state.isEmpty, true);
      expect(state.isNotEmpty, false);
      expect(state.count, 0);
    });

    test('can create state with history', () {
      const state = SearchHistoryState(
        history: ['query1', 'query2', 'query3'],
        isLoading: false,
      );

      expect(state.history, ['query1', 'query2', 'query3']);
      expect(state.count, 3);
      expect(state.isLoading, false);
      expect(state.isEmpty, false);
      expect(state.isNotEmpty, true);
    });

    test('copyWith updates history', () {
      const state = SearchHistoryState(history: ['old query']);
      final newState = state.copyWith(history: ['new query', 'another']);

      expect(newState.history, ['new query', 'another']);
      expect(newState.count, 2);
    });

    test('copyWith updates isLoading', () {
      const state = SearchHistoryState(isLoading: false);
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, true);
    });

    test('copyWith preserves values when not specified', () {
      const state = SearchHistoryState(
        history: ['query1', 'query2'],
        isLoading: true,
      );
      final newState = state.copyWith();

      expect(newState.history, ['query1', 'query2']);
      expect(newState.isLoading, true);
    });

    test('props contains history and isLoading', () {
      const state = SearchHistoryState(
        history: ['query'],
        isLoading: true,
      );

      expect(state.props.length, 2);
      expect(state.props[0], ['query']);
      expect(state.props[1], true);
    });

    test('states with same values are equal', () {
      const state1 = SearchHistoryState(
        history: ['query1', 'query2'],
        isLoading: false,
      );
      const state2 = SearchHistoryState(
        history: ['query1', 'query2'],
        isLoading: false,
      );

      expect(state1, equals(state2));
    });

    test('states with different history are not equal', () {
      const state1 = SearchHistoryState(history: ['query1']);
      const state2 = SearchHistoryState(history: ['query2']);

      expect(state1, isNot(equals(state2)));
    });

    test('states with different isLoading are not equal', () {
      const state1 = SearchHistoryState(isLoading: true);
      const state2 = SearchHistoryState(isLoading: false);

      expect(state1, isNot(equals(state2)));
    });

    test('isEmpty and isNotEmpty work correctly', () {
      expect(const SearchHistoryState().isEmpty, true);
      expect(const SearchHistoryState().isNotEmpty, false);
      expect(const SearchHistoryState(history: ['q']).isEmpty, false);
      expect(const SearchHistoryState(history: ['q']).isNotEmpty, true);
    });

    test('count returns correct number of items', () {
      expect(const SearchHistoryState().count, 0);
      expect(const SearchHistoryState(history: ['q']).count, 1);
      expect(const SearchHistoryState(history: ['a', 'b', 'c']).count, 3);
    });
  });

  group('SearchHistoryCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state starts loading', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = SearchHistoryCubit();

      // Wait for loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.history, isEmpty);
      expect(cubit.state.isLoading, false);

      await cubit.close();
    });

    test('loads saved history from preferences', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.searchHistory: ['query1', 'query2', 'query3'],
      });

      final cubit = SearchHistoryCubit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.history, ['query1', 'query2', 'query3']);
      expect(cubit.state.isLoading, false);

      await cubit.close();
    });

    test('addSearchQuery adds query to history', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addSearchQuery('new search');

      expect(cubit.state.history, ['new search']);
      expect(cubit.state.count, 1);

      await cubit.close();
    });

    test('addSearchQuery adds to beginning of list', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.searchHistory: ['old search'],
      });
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addSearchQuery('new search');

      expect(cubit.state.history.first, 'new search');
      expect(cubit.state.history.last, 'old search');

      await cubit.close();
    });

    test('addSearchQuery moves existing query to top', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.searchHistory: ['first', 'second', 'third'],
      });
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addSearchQuery('third');

      expect(cubit.state.history, ['third', 'first', 'second']);
      expect(cubit.state.count, 3);

      await cubit.close();
    });

    test('addSearchQuery limits history to maxHistoryItems', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      // Add more items than the max
      for (int i = 0; i < SearchConstants.maxHistoryItems + 5; i++) {
        await cubit.addSearchQuery('query $i');
      }

      expect(cubit.state.count, SearchConstants.maxHistoryItems);
      // Most recent should be first
      expect(cubit.state.history.first,
          'query ${SearchConstants.maxHistoryItems + 4}');

      await cubit.close();
    });

    test('addSearchQuery ignores empty queries', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addSearchQuery('');
      await cubit.addSearchQuery('   ');

      expect(cubit.state.count, 0);

      await cubit.close();
    });

    test('addSearchQuery ignores queries shorter than minQueryLength', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addSearchQuery('a');

      expect(cubit.state.count, 0);

      await cubit.close();
    });

    test('addSearchQuery trims whitespace', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addSearchQuery('  test query  ');

      expect(cubit.state.history, ['test query']);

      await cubit.close();
    });

    test('removeQuery removes specific item', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.searchHistory: ['first', 'second', 'third'],
      });
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.removeQuery('second');

      expect(cubit.state.history, ['first', 'third']);
      expect(cubit.state.count, 2);

      await cubit.close();
    });

    test('removeQuery does nothing for non-existent query', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.searchHistory: ['first', 'second'],
      });
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.removeQuery('non-existent');

      expect(cubit.state.history, ['first', 'second']);
      expect(cubit.state.count, 2);

      await cubit.close();
    });

    test('clearHistory removes all items', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.searchHistory: ['query1', 'query2', 'query3'],
      });
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.count, 3);

      await cubit.clearHistory();

      expect(cubit.state.history, isEmpty);
      expect(cubit.state.count, 0);

      await cubit.close();
    });

    test('hasQuery returns true for existing query', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.searchHistory: ['existing query'],
      });
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.hasQuery('existing query'), true);
      expect(cubit.hasQuery('non-existent'), false);

      await cubit.close();
    });

    test('history is persisted to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.addSearchQuery('search 1');
      await cubit.addSearchQuery('search 2');

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(PreferenceKeys.searchHistory);

      expect(saved, isNotNull);
      expect(saved, ['search 2', 'search 1']);

      await cubit.close();
    });

    test('clearHistory removes from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.searchHistory: ['query1', 'query2'],
      });
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.clearHistory();

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(PreferenceKeys.searchHistory);

      expect(saved, isNull);

      await cubit.close();
    });

    test('multiple operations work correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      await cubit.addSearchQuery('query 1');
      await cubit.addSearchQuery('query 2');
      await cubit.addSearchQuery('query 3');
      expect(cubit.state.count, 3);
      expect(cubit.state.history, ['query 3', 'query 2', 'query 1']);

      await cubit.removeQuery('query 2');
      expect(cubit.state.count, 2);
      expect(cubit.state.history, ['query 3', 'query 1']);

      // Re-add query 1 should move it to top
      await cubit.addSearchQuery('query 1');
      expect(cubit.state.count, 2);
      expect(cubit.state.history, ['query 1', 'query 3']);

      await cubit.clearHistory();
      expect(cubit.state.count, 0);
      expect(cubit.state.history, isEmpty);

      await cubit.close();
    });

    test('reload after save retrieves correct data', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit1 = SearchHistoryCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit1.addSearchQuery('persistent query');
      await cubit1.close();

      // Create new cubit to simulate app restart
      final cubit2 = SearchHistoryCubit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit2.state.history, ['persistent query']);

      await cubit2.close();
    });
  });
}
