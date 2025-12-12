import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// State for font size preferences
class FontSizeState extends Equatable {
  final double hadithFontSize;
  final double descriptionFontSize;
  final double minFontSize;
  final double maxFontSize;
  final double fontSizeStep;

  const FontSizeState({
    this.hadithFontSize = FontSizeConstants.defaultHadithFontSize,
    this.descriptionFontSize = FontSizeConstants.defaultDescriptionFontSize,
    this.minFontSize = FontSizeConstants.minFontSize,
    this.maxFontSize = FontSizeConstants.maxFontSize,
    this.fontSizeStep = FontSizeConstants.fontSizeStep,
  });

  FontSizeState copyWith({
    double? hadithFontSize,
    double? descriptionFontSize,
  }) {
    return FontSizeState(
      hadithFontSize: hadithFontSize ?? this.hadithFontSize,
      descriptionFontSize: descriptionFontSize ?? this.descriptionFontSize,
      minFontSize: minFontSize,
      maxFontSize: maxFontSize,
      fontSizeStep: fontSizeStep,
    );
  }

  @override
  List<Object> get props => [
        hadithFontSize,
        descriptionFontSize,
        minFontSize,
        maxFontSize,
        fontSizeStep,
      ];
}

/// Cubit for managing font size preferences
class FontSizeCubit extends Cubit<FontSizeState> {
  FontSizeCubit() : super(const FontSizeState());

  /// Load saved font size preferences from storage
  Future<void> loadFontSizePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final hadithSize = prefs.getDouble(PreferenceKeys.hadithFontSize) ??
        FontSizeConstants.defaultHadithFontSize;
    final descriptionSize = prefs.getDouble(PreferenceKeys.descriptionFontSize) ??
        FontSizeConstants.defaultDescriptionFontSize;

    emit(state.copyWith(
      hadithFontSize: hadithSize,
      descriptionFontSize: descriptionSize,
    ));
  }

  /// Save current font size preferences to storage
  Future<void> saveFontSizePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(PreferenceKeys.hadithFontSize, state.hadithFontSize);
    await prefs.setDouble(
      PreferenceKeys.descriptionFontSize,
      state.descriptionFontSize,
    );
  }

  // Increase hadith font size
  void increaseHadithFontSize() {
    if (state.hadithFontSize < state.maxFontSize) {
      final newSize = state.hadithFontSize + state.fontSizeStep;
      emit(state.copyWith(hadithFontSize: newSize));
      saveFontSizePreferences();
    }
  }

  // Decrease hadith font size
  void decreaseHadithFontSize() {
    if (state.hadithFontSize > state.minFontSize) {
      final newSize = state.hadithFontSize - state.fontSizeStep;
      emit(state.copyWith(hadithFontSize: newSize));
      saveFontSizePreferences();
    }
  }

  // Increase description font size
  void increaseDescriptionFontSize() {
    if (state.descriptionFontSize < state.maxFontSize) {
      final newSize = state.descriptionFontSize + state.fontSizeStep;
      emit(state.copyWith(descriptionFontSize: newSize));
      saveFontSizePreferences();
    }
  }

  // Decrease description font size
  void decreaseDescriptionFontSize() {
    if (state.descriptionFontSize > state.minFontSize) {
      final newSize = state.descriptionFontSize - state.fontSizeStep;
      emit(state.copyWith(descriptionFontSize: newSize));
      saveFontSizePreferences();
    }
  }
}
