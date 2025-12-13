import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_state.dart';

/// Cubit for managing app language
class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(const LanguageState()) {
    loadLanguage();
  }

  static const String _languageKey = 'app_language';

  /// Loads the saved language preference
  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);

      if (languageCode != null) {
        final language = AppLanguage.fromCode(languageCode);
        emit(state.copyWith(language: language, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Changes the app language
  Future<void> changeLanguage(AppLanguage language) async {
    if (state.language == language) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
      emit(state.copyWith(language: language));
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  /// Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    final newLanguage = state.isArabic ? AppLanguage.english : AppLanguage.arabic;
    await changeLanguage(newLanguage);
  }
}
