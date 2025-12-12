import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/core/constants.dart';
import 'package:hadith_nawawi_audio/cubit/font_size_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FontSizeState', () {
    test('default state has correct initial values', () {
      const state = FontSizeState();

      expect(state.hadithFontSize, FontSizeConstants.defaultHadithFontSize);
      expect(
        state.descriptionFontSize,
        FontSizeConstants.defaultDescriptionFontSize,
      );
      expect(state.minFontSize, FontSizeConstants.minFontSize);
      expect(state.maxFontSize, FontSizeConstants.maxFontSize);
      expect(state.fontSizeStep, FontSizeConstants.fontSizeStep);
    });

    test('copyWith creates new state with updated hadith font size', () {
      const state = FontSizeState();
      final newState = state.copyWith(hadithFontSize: 24.0);

      expect(newState.hadithFontSize, 24.0);
      expect(
        newState.descriptionFontSize,
        state.descriptionFontSize,
      );
    });

    test('copyWith creates new state with updated description font size', () {
      const state = FontSizeState();
      final newState = state.copyWith(descriptionFontSize: 20.0);

      expect(newState.descriptionFontSize, 20.0);
      expect(newState.hadithFontSize, state.hadithFontSize);
    });

    test('copyWith can update both font sizes', () {
      const state = FontSizeState();
      final newState = state.copyWith(
        hadithFontSize: 24.0,
        descriptionFontSize: 20.0,
      );

      expect(newState.hadithFontSize, 24.0);
      expect(newState.descriptionFontSize, 20.0);
    });

    test('props returns all relevant properties', () {
      const state = FontSizeState();

      expect(state.props, contains(state.hadithFontSize));
      expect(state.props, contains(state.descriptionFontSize));
      expect(state.props, contains(state.minFontSize));
      expect(state.props, contains(state.maxFontSize));
      expect(state.props, contains(state.fontSizeStep));
    });

    test('states with same values are equal', () {
      const state1 = FontSizeState();
      const state2 = FontSizeState();

      expect(state1, equals(state2));
    });

    test('states with different values are not equal', () {
      const state1 = FontSizeState();
      final state2 = state1.copyWith(hadithFontSize: 24.0);

      expect(state1, isNot(equals(state2)));
    });
  });

  group('FontSizeCubit', () {
    setUp(() {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state has default font sizes', () {
      final cubit = FontSizeCubit();

      expect(
        cubit.state.hadithFontSize,
        FontSizeConstants.defaultHadithFontSize,
      );
      expect(
        cubit.state.descriptionFontSize,
        FontSizeConstants.defaultDescriptionFontSize,
      );

      cubit.close();
    });

    blocTest<FontSizeCubit, FontSizeState>(
      'increaseHadithFontSize increases font size by step',
      build: () => FontSizeCubit(),
      act: (cubit) => cubit.increaseHadithFontSize(),
      expect: () => [
        FontSizeState(
          hadithFontSize: FontSizeConstants.defaultHadithFontSize +
              FontSizeConstants.fontSizeStep,
        ),
      ],
    );

    blocTest<FontSizeCubit, FontSizeState>(
      'decreaseHadithFontSize decreases font size by step',
      build: () => FontSizeCubit(),
      act: (cubit) => cubit.decreaseHadithFontSize(),
      expect: () => [
        FontSizeState(
          hadithFontSize: FontSizeConstants.defaultHadithFontSize -
              FontSizeConstants.fontSizeStep,
        ),
      ],
    );

    blocTest<FontSizeCubit, FontSizeState>(
      'increaseDescriptionFontSize increases font size by step',
      build: () => FontSizeCubit(),
      act: (cubit) => cubit.increaseDescriptionFontSize(),
      expect: () => [
        FontSizeState(
          descriptionFontSize: FontSizeConstants.defaultDescriptionFontSize +
              FontSizeConstants.fontSizeStep,
        ),
      ],
    );

    blocTest<FontSizeCubit, FontSizeState>(
      'decreaseDescriptionFontSize decreases font size by step',
      build: () => FontSizeCubit(),
      act: (cubit) => cubit.decreaseDescriptionFontSize(),
      expect: () => [
        FontSizeState(
          descriptionFontSize: FontSizeConstants.defaultDescriptionFontSize -
              FontSizeConstants.fontSizeStep,
        ),
      ],
    );

    blocTest<FontSizeCubit, FontSizeState>(
      'increaseHadithFontSize does not exceed max font size',
      seed: () => FontSizeState(hadithFontSize: FontSizeConstants.maxFontSize),
      build: () => FontSizeCubit(),
      act: (cubit) => cubit.increaseHadithFontSize(),
      expect: () => [], // No state change expected
    );

    blocTest<FontSizeCubit, FontSizeState>(
      'decreaseHadithFontSize does not go below min font size',
      seed: () => FontSizeState(hadithFontSize: FontSizeConstants.minFontSize),
      build: () => FontSizeCubit(),
      act: (cubit) => cubit.decreaseHadithFontSize(),
      expect: () => [], // No state change expected
    );

    blocTest<FontSizeCubit, FontSizeState>(
      'increaseDescriptionFontSize does not exceed max font size',
      seed: () =>
          FontSizeState(descriptionFontSize: FontSizeConstants.maxFontSize),
      build: () => FontSizeCubit(),
      act: (cubit) => cubit.increaseDescriptionFontSize(),
      expect: () => [], // No state change expected
    );

    blocTest<FontSizeCubit, FontSizeState>(
      'decreaseDescriptionFontSize does not go below min font size',
      seed: () =>
          FontSizeState(descriptionFontSize: FontSizeConstants.minFontSize),
      build: () => FontSizeCubit(),
      act: (cubit) => cubit.decreaseDescriptionFontSize(),
      expect: () => [], // No state change expected
    );

    blocTest<FontSizeCubit, FontSizeState>(
      'multiple increases work correctly',
      build: () => FontSizeCubit(),
      act: (cubit) {
        cubit.increaseHadithFontSize();
        cubit.increaseHadithFontSize();
        cubit.increaseHadithFontSize();
      },
      expect: () => [
        FontSizeState(
          hadithFontSize: FontSizeConstants.defaultHadithFontSize +
              FontSizeConstants.fontSizeStep,
        ),
        FontSizeState(
          hadithFontSize: FontSizeConstants.defaultHadithFontSize +
              (FontSizeConstants.fontSizeStep * 2),
        ),
        FontSizeState(
          hadithFontSize: FontSizeConstants.defaultHadithFontSize +
              (FontSizeConstants.fontSizeStep * 3),
        ),
      ],
    );

    test('loadFontSizePreferences loads saved values', () async {
      // Set up mock preferences with saved values
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.hadithFontSize: 24.0,
        PreferenceKeys.descriptionFontSize: 20.0,
      });

      final cubit = FontSizeCubit();
      await cubit.loadFontSizePreferences();

      expect(cubit.state.hadithFontSize, 24.0);
      expect(cubit.state.descriptionFontSize, 20.0);

      cubit.close();
    });

    test('loadFontSizePreferences uses defaults when no saved values', () async {
      SharedPreferences.setMockInitialValues({});

      final cubit = FontSizeCubit();
      await cubit.loadFontSizePreferences();

      expect(
        cubit.state.hadithFontSize,
        FontSizeConstants.defaultHadithFontSize,
      );
      expect(
        cubit.state.descriptionFontSize,
        FontSizeConstants.defaultDescriptionFontSize,
      );

      cubit.close();
    });

    test('saveFontSizePreferences saves current values', () async {
      SharedPreferences.setMockInitialValues({});

      final cubit = FontSizeCubit();
      cubit.increaseHadithFontSize();
      await cubit.saveFontSizePreferences();

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getDouble(PreferenceKeys.hadithFontSize),
        FontSizeConstants.defaultHadithFontSize + FontSizeConstants.fontSizeStep,
      );

      cubit.close();
    });
  });
}
