import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/core/constants.dart';
import 'package:hadith_nawawi_audio/cubit/reading_stats_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/reading_stats_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReadingStatsState', () {
    test('default state has empty read indices and loading false', () {
      const state = ReadingStatsState();

      expect(state.readHadithIndices, isEmpty);
      expect(state.isLoading, false);
      expect(state.totalHadiths, 42);
      expect(state.readCount, 0);
      expect(state.progressPercentage, 0.0);
      expect(state.progressPercent, 0);
      expect(state.isComplete, false);
    });

    test('can create state with read indices', () {
      const state = ReadingStatsState(
        readHadithIndices: {1, 5, 10},
        isLoading: false,
        totalHadiths: 42,
      );

      expect(state.readHadithIndices, {1, 5, 10});
      expect(state.readCount, 3);
      expect(state.isLoading, false);
    });

    test('isRead returns true for read hadiths', () {
      const state = ReadingStatsState(readHadithIndices: {1, 5, 10});

      expect(state.isRead(1), true);
      expect(state.isRead(5), true);
      expect(state.isRead(10), true);
      expect(state.isRead(2), false);
      expect(state.isRead(99), false);
    });

    test('progressPercentage calculates correctly', () {
      const state = ReadingStatsState(
        readHadithIndices: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21},
        totalHadiths: 42,
      );

      expect(state.progressPercentage, closeTo(0.5, 0.01));
      expect(state.progressPercent, 50);
    });

    test('isComplete returns true when all read', () {
      final allIndices = <int>{};
      for (int i = 1; i <= 42; i++) {
        allIndices.add(i);
      }

      final state = ReadingStatsState(
        readHadithIndices: allIndices,
        totalHadiths: 42,
      );

      expect(state.isComplete, true);
      expect(state.progressPercent, 100);
    });

    test('remainingCount calculates correctly', () {
      const state = ReadingStatsState(
        readHadithIndices: {1, 2, 3},
        totalHadiths: 42,
      );

      expect(state.remainingCount, 39);
    });

    test('copyWith updates readHadithIndices', () {
      const state = ReadingStatsState(readHadithIndices: {1, 2});
      final newState = state.copyWith(readHadithIndices: {3, 4, 5});

      expect(newState.readHadithIndices, {3, 4, 5});
      expect(newState.readCount, 3);
    });

    test('copyWith updates isLoading', () {
      const state = ReadingStatsState(isLoading: false);
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, true);
    });

    test('copyWith updates totalHadiths', () {
      const state = ReadingStatsState(totalHadiths: 42);
      final newState = state.copyWith(totalHadiths: 50);

      expect(newState.totalHadiths, 50);
    });

    test('copyWith preserves values when not specified', () {
      const state = ReadingStatsState(
        readHadithIndices: {1, 2, 3},
        isLoading: true,
        totalHadiths: 42,
      );
      final newState = state.copyWith();

      expect(newState.readHadithIndices, {1, 2, 3});
      expect(newState.isLoading, true);
      expect(newState.totalHadiths, 42);
    });

    test('props contains all properties', () {
      const state = ReadingStatsState(
        readHadithIndices: {1, 2},
        isLoading: true,
        totalHadiths: 42,
      );

      expect(state.props.length, 3);
      expect(state.props[0], {1, 2});
      expect(state.props[1], true);
      expect(state.props[2], 42);
    });

    test('states with same values are equal', () {
      const state1 = ReadingStatsState(
        readHadithIndices: {1, 2, 3},
        isLoading: false,
        totalHadiths: 42,
      );
      const state2 = ReadingStatsState(
        readHadithIndices: {1, 2, 3},
        isLoading: false,
        totalHadiths: 42,
      );

      expect(state1, equals(state2));
    });

    test('states with different read indices are not equal', () {
      const state1 = ReadingStatsState(readHadithIndices: {1, 2, 3});
      const state2 = ReadingStatsState(readHadithIndices: {4, 5, 6});

      expect(state1, isNot(equals(state2)));
    });

    test('progressPercentage handles zero total', () {
      const state = ReadingStatsState(
        readHadithIndices: {1, 2},
        totalHadiths: 0,
      );

      expect(state.progressPercentage, 0.0);
    });
  });

  group('ReadingStatsCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state starts loading', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      // Wait for loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.readHadithIndices, isEmpty);
      expect(cubit.state.isLoading, false);

      await cubit.close();
    });

    test('loads saved read hadiths from preferences', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.readHadiths: ['1', '5', '10'],
      });

      final cubit = ReadingStatsCubit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.readHadithIndices, {1, 5, 10});
      expect(cubit.state.isLoading, false);

      await cubit.close();
    });

    test('markAsRead adds hadith to read set', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.markAsRead(5);

      expect(cubit.state.isRead(5), true);
      expect(cubit.state.readCount, 1);

      await cubit.close();
    });

    test('markAsRead does not duplicate existing read hadith', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.readHadiths: ['5'],
      });
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.markAsRead(5);

      expect(cubit.state.readCount, 1);

      await cubit.close();
    });

    test('markAsUnread removes hadith from read set', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.readHadiths: ['5', '10', '15'],
      });
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.markAsUnread(10);

      expect(cubit.state.isRead(10), false);
      expect(cubit.state.isRead(5), true);
      expect(cubit.state.isRead(15), true);
      expect(cubit.state.readCount, 2);

      await cubit.close();
    });

    test('markAsUnread does nothing for unread hadith', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.readHadiths: ['5'],
      });
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.markAsUnread(10);

      expect(cubit.state.readCount, 1);
      expect(cubit.state.isRead(5), true);

      await cubit.close();
    });

    test('toggleReadStatus toggles read status', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      // Add
      await cubit.toggleReadStatus(5);
      expect(cubit.state.isRead(5), true);

      // Remove
      await cubit.toggleReadStatus(5);
      expect(cubit.state.isRead(5), false);

      await cubit.close();
    });

    test('resetProgress clears all read hadiths', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.readHadiths: ['1', '2', '3', '4', '5'],
      });
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.readCount, 5);

      await cubit.resetProgress();

      expect(cubit.state.readCount, 0);
      expect(cubit.state.readHadithIndices, isEmpty);

      await cubit.close();
    });

    test('markAllAsRead marks all hadiths as read', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.markAllAsRead(42);

      expect(cubit.state.readCount, 42);
      expect(cubit.state.isComplete, true);

      await cubit.close();
    });

    test('isRead method works correctly', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.readHadiths: ['5', '10'],
      });
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.isRead(5), true);
      expect(cubit.isRead(10), true);
      expect(cubit.isRead(1), false);
      expect(cubit.isRead(15), false);

      await cubit.close();
    });

    test('sortedReadHadiths returns sorted list', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.readHadiths: ['10', '5', '1', '15', '3'],
      });
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.sortedReadHadiths, [1, 3, 5, 10, 15]);

      await cubit.close();
    });

    test('getUnreadHadiths returns unread list', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.readHadiths: ['1', '2', '3'],
      });
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      final unread = cubit.getUnreadHadiths(5);
      expect(unread, [4, 5]);

      await cubit.close();
    });

    test('setTotalHadiths updates total count', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      cubit.setTotalHadiths(50);

      expect(cubit.state.totalHadiths, 50);

      await cubit.close();
    });

    test('setTotalHadiths ignores invalid count', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      cubit.setTotalHadiths(0);
      cubit.setTotalHadiths(-1);

      expect(cubit.state.totalHadiths, 42); // Default value

      await cubit.close();
    });

    test('markAsRead ignores invalid index below minimum', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.markAsRead(0);
      await cubit.markAsRead(-1);

      expect(cubit.state.readCount, 0);

      await cubit.close();
    });

    test('markAsRead ignores invalid index above maximum', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.markAsRead(101);
      await cubit.markAsRead(999);

      expect(cubit.state.readCount, 0);

      await cubit.close();
    });

    test('read hadiths are persisted to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.markAsRead(5);
      await cubit.markAsRead(10);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(PreferenceKeys.readHadiths);

      expect(saved, isNotNull);
      expect(saved!.contains('5'), true);
      expect(saved.contains('10'), true);

      await cubit.close();
    });

    test('loadStats filters out invalid indices', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.readHadiths: ['5', '0', '-1', '101', '10', 'invalid'],
      });
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      // Only valid indices (5 and 10) should be loaded
      expect(cubit.state.readHadithIndices, {5, 10});
      expect(cubit.state.readCount, 2);

      await cubit.close();
    });

    test('multiple operations work correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ReadingStatsCubit();

      await Future.delayed(const Duration(milliseconds: 100));

      await cubit.markAsRead(1);
      await cubit.markAsRead(2);
      await cubit.markAsRead(3);
      expect(cubit.state.readCount, 3);

      await cubit.markAsUnread(2);
      expect(cubit.state.readCount, 2);
      expect(cubit.state.isRead(2), false);

      await cubit.toggleReadStatus(3);
      expect(cubit.state.readCount, 1);
      expect(cubit.state.isRead(3), false);

      await cubit.toggleReadStatus(5);
      expect(cubit.state.readCount, 2);
      expect(cubit.state.isRead(5), true);

      expect(cubit.sortedReadHadiths, [1, 5]);

      await cubit.close();
    });
  });
}
