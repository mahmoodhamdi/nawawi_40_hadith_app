import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/core/constants.dart';
import 'package:hadith_nawawi_audio/cubit/last_read_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/last_read_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LastReadState', () {
    test('default state has null values', () {
      const state = LastReadState();

      expect(state.hadithIndex, isNull);
      expect(state.lastReadTime, isNull);
    });

    test('can create state with values', () {
      final now = DateTime.now();
      final state = LastReadState(hadithIndex: 5, lastReadTime: now);

      expect(state.hadithIndex, 5);
      expect(state.lastReadTime, now);
    });

    test('copyWith updates hadith index', () {
      final state = LastReadState(hadithIndex: 1, lastReadTime: DateTime.now());
      final newState = state.copyWith(hadithIndex: 10);

      expect(newState.hadithIndex, 10);
      expect(newState.lastReadTime, state.lastReadTime);
    });

    test('copyWith updates last read time', () {
      final oldTime = DateTime(2024, 1, 1);
      final newTime = DateTime(2024, 12, 1);
      final state = LastReadState(hadithIndex: 5, lastReadTime: oldTime);
      final newState = state.copyWith(lastReadTime: newTime);

      expect(newState.hadithIndex, 5);
      expect(newState.lastReadTime, newTime);
    });

    test('props contains hadith index and time', () {
      final time = DateTime(2024, 6, 15);
      final state = LastReadState(hadithIndex: 7, lastReadTime: time);

      expect(state.props, [7, time]);
    });

    test('props handles null values', () {
      const state = LastReadState();

      expect(state.props, [null, null]);
    });

    test('states with same values are equal', () {
      final time = DateTime(2024, 6, 15);
      final state1 = LastReadState(hadithIndex: 5, lastReadTime: time);
      final state2 = LastReadState(hadithIndex: 5, lastReadTime: time);

      expect(state1, equals(state2));
    });

    test('states with different values are not equal', () {
      final time = DateTime(2024, 6, 15);
      final state1 = LastReadState(hadithIndex: 5, lastReadTime: time);
      final state2 = LastReadState(hadithIndex: 6, lastReadTime: time);

      expect(state1, isNot(equals(state2)));
    });

    test('null states are equal', () {
      const state1 = LastReadState();
      const state2 = LastReadState();

      expect(state1, equals(state2));
    });
  });

  group('LastReadCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state has null values', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = LastReadCubit();

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.hadithIndex, isNull);
      expect(cubit.state.lastReadTime, isNull);

      await cubit.close();
    });

    test('loads saved last read info from preferences', () async {
      final savedTime = DateTime(2024, 6, 15, 10, 30);
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadHadith: 15,
        PreferenceKeys.lastReadTime: savedTime.toIso8601String(),
      });

      final cubit = LastReadCubit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.hadithIndex, 15);
      expect(cubit.state.lastReadTime, savedTime);

      await cubit.close();
    });

    blocTest<LastReadCubit, LastReadState>(
      'updateLastReadHadith updates state and saves to preferences',
      setUp: () => SharedPreferences.setMockInitialValues({}),
      build: () => LastReadCubit(),
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        await cubit.updateLastReadHadith(10);
      },
      verify: (cubit) async {
        expect(cubit.state.hadithIndex, 10);
        expect(cubit.state.lastReadTime, isNotNull);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(PreferenceKeys.lastReadHadith), 10);
      },
      skip: 1, // Skip initial state
    );

    blocTest<LastReadCubit, LastReadState>(
      'clearLastReadData resets state',
      setUp: () => SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadHadith: 20,
        PreferenceKeys.lastReadTime: DateTime.now().toIso8601String(),
      }),
      build: () => LastReadCubit(),
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        await cubit.clearLastReadData();
      },
      verify: (cubit) async {
        expect(cubit.state.hadithIndex, isNull);
        expect(cubit.state.lastReadTime, isNull);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(PreferenceKeys.lastReadHadith), isNull);
        expect(prefs.getString(PreferenceKeys.lastReadTime), isNull);
      },
    );

    test('updateLastReadHadith multiple times updates correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = LastReadCubit();

      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.updateLastReadHadith(5);
      expect(cubit.state.hadithIndex, 5);

      await cubit.updateLastReadHadith(10);
      expect(cubit.state.hadithIndex, 10);

      await cubit.updateLastReadHadith(42);
      expect(cubit.state.hadithIndex, 42);

      await cubit.close();
    });

    test('loadLastReadInfo handles missing data gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = LastReadCubit();

      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.loadLastReadInfo();

      expect(cubit.state.hadithIndex, isNull);
      expect(cubit.state.lastReadTime, isNull);

      await cubit.close();
    });

    test('loadLastReadInfo handles partial data', () async {
      // Only hadith index saved, no time
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.lastReadHadith: 25,
      });

      final cubit = LastReadCubit();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.hadithIndex, 25);
      expect(cubit.state.lastReadTime, isNull);

      await cubit.close();
    });
  });
}
