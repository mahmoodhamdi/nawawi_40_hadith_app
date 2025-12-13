import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Available app languages
enum AppLanguage {
  arabic('ar', 'العربية', TextDirection.rtl),
  english('en', 'English', TextDirection.ltr);

  final String code;
  final String displayName;
  final TextDirection textDirection;

  const AppLanguage(this.code, this.displayName, this.textDirection);

  /// Get language from code
  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.arabic,
    );
  }
}

/// State for the language cubit
class LanguageState extends Equatable {
  /// The current app language
  final AppLanguage language;

  /// Whether the state is currently loading
  final bool isLoading;

  const LanguageState({
    this.language = AppLanguage.arabic,
    this.isLoading = true,
  });

  /// Get the current locale
  Locale get locale => Locale(language.code);

  /// Get the text direction
  TextDirection get textDirection => language.textDirection;

  /// Check if current language is Arabic
  bool get isArabic => language == AppLanguage.arabic;

  /// Check if current language is English
  bool get isEnglish => language == AppLanguage.english;

  /// Create a copy with updated values
  LanguageState copyWith({
    AppLanguage? language,
    bool? isLoading,
  }) {
    return LanguageState(
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [language, isLoading];
}
