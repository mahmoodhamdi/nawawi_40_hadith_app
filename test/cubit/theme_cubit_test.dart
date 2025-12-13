import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/core/constants.dart';
import 'package:hadith_nawawi_audio/core/theme/app_theme.dart';
import 'package:hadith_nawawi_audio/cubit/theme_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeState', () {
    test('default state has system theme type', () {
      const state = ThemeState();
      expect(state.themeType, AppThemeType.system);
    });

    test('can create state with specific theme type', () {
      const state = ThemeState(themeType: AppThemeType.dark);
      expect(state.themeType, AppThemeType.dark);
    });

    test('copyWith creates new state with updated theme', () {
      const state = ThemeState(themeType: AppThemeType.light);
      final newState = state.copyWith(themeType: AppThemeType.dark);

      expect(newState.themeType, AppThemeType.dark);
      expect(state.themeType, AppThemeType.light); // Original unchanged
    });

    test('copyWith without parameters returns same values', () {
      const state = ThemeState(themeType: AppThemeType.blue);
      final newState = state.copyWith();

      expect(newState.themeType, state.themeType);
    });

    test('props contains theme type', () {
      const state = ThemeState(themeType: AppThemeType.purple);
      expect(state.props, [AppThemeType.purple]);
    });

    test('states with same theme type are equal', () {
      const state1 = ThemeState(themeType: AppThemeType.dark);
      const state2 = ThemeState(themeType: AppThemeType.dark);

      expect(state1, equals(state2));
    });

    test('states with different theme types are not equal', () {
      const state1 = ThemeState(themeType: AppThemeType.light);
      const state2 = ThemeState(themeType: AppThemeType.dark);

      expect(state1, isNot(equals(state2)));
    });
  });

  group('AppThemeType', () {
    test('all theme types are defined', () {
      expect(AppThemeType.values, contains(AppThemeType.light));
      expect(AppThemeType.values, contains(AppThemeType.dark));
      expect(AppThemeType.values, contains(AppThemeType.blue));
      expect(AppThemeType.values, contains(AppThemeType.purple));
      expect(AppThemeType.values, contains(AppThemeType.system));
    });

    test('theme types have correct indices', () {
      expect(AppThemeType.light.index, 0);
      expect(AppThemeType.dark.index, 1);
      expect(AppThemeType.blue.index, 2);
      expect(AppThemeType.purple.index, 3);
      expect(AppThemeType.system.index, 4);
    });
  });

  group('ThemeCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state has system theme', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ThemeCubit();

      // Wait for loadTheme to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.themeType, AppThemeType.system);
      await cubit.close();
    });

    test('loads saved theme from preferences', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.theme: AppThemeType.dark.index,
      });

      final cubit = ThemeCubit();

      // Wait for loadTheme to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.themeType, AppThemeType.dark);
      await cubit.close();
    });

    test('changeTheme updates to light theme', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ThemeCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.changeTheme(AppThemeType.light);

      expect(cubit.state.themeType, AppThemeType.light);
      await cubit.close();
    });

    test('changeTheme updates to dark theme', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ThemeCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.changeTheme(AppThemeType.dark);

      expect(cubit.state.themeType, AppThemeType.dark);
      await cubit.close();
    });

    test('changeTheme updates to blue theme', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ThemeCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.changeTheme(AppThemeType.blue);

      expect(cubit.state.themeType, AppThemeType.blue);
      await cubit.close();
    });

    test('changeTheme updates to purple theme', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ThemeCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.changeTheme(AppThemeType.purple);

      expect(cubit.state.themeType, AppThemeType.purple);
      await cubit.close();
    });

    test('changeTheme updates to system theme from dark', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.theme: AppThemeType.dark.index,
      });
      final cubit = ThemeCubit();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.themeType, AppThemeType.dark);

      await cubit.changeTheme(AppThemeType.system);
      expect(cubit.state.themeType, AppThemeType.system);

      await cubit.close();
    });

    test('changeTheme saves to preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ThemeCubit();

      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.changeTheme(AppThemeType.purple);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PreferenceKeys.theme), AppThemeType.purple.index);

      await cubit.close();
    });

    test('multiple theme changes work correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ThemeCubit();

      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.changeTheme(AppThemeType.dark);
      expect(cubit.state.themeType, AppThemeType.dark);

      await cubit.changeTheme(AppThemeType.light);
      expect(cubit.state.themeType, AppThemeType.light);

      await cubit.changeTheme(AppThemeType.blue);
      expect(cubit.state.themeType, AppThemeType.blue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(PreferenceKeys.theme), AppThemeType.blue.index);

      await cubit.close();
    });
  });
}
