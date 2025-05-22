import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Font Size State
class FontSizeState extends Equatable {
  final double hadithFontSize;
  final double descriptionFontSize;
  final double minFontSize;
  final double maxFontSize;
  final double fontSizeStep;

  const FontSizeState({
    this.hadithFontSize = 18.0,
    this.descriptionFontSize = 16.0,
    this.minFontSize = 12.0,
    this.maxFontSize = 30.0,
    this.fontSizeStep = 2.0,
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

// Font Size Cubit
class FontSizeCubit extends Cubit<FontSizeState> {
  FontSizeCubit() : super(const FontSizeState());

  // Load saved preferences
  Future<void> loadFontSizePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final hadithSize = prefs.getDouble('hadith_font_size') ?? 18.0;
    final descriptionSize = prefs.getDouble('description_font_size') ?? 16.0;
    
    emit(state.copyWith(
      hadithFontSize: hadithSize,
      descriptionFontSize: descriptionSize,
    ));
  }

  // Save preferences
  Future<void> saveFontSizePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hadith_font_size', state.hadithFontSize);
    await prefs.setDouble('description_font_size', state.descriptionFontSize);
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
