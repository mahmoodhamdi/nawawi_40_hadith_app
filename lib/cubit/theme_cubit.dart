import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../services/preferences_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    loadTheme();
  }

  // Load saved theme from preferences
  Future<void> loadTheme() async {
    final savedThemeIndex = await PreferencesService.getSavedTheme();
    if (savedThemeIndex != null) {
      final themeType = AppThemeType.values[savedThemeIndex];
      emit(ThemeState(themeType: themeType));
    }
  }

  // Change the theme and save to preferences
  Future<void> changeTheme(AppThemeType themeType) async {
    await PreferencesService.saveTheme(themeType.index);
    emit(ThemeState(themeType: themeType));
  }
}
