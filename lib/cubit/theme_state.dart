import 'package:equatable/equatable.dart';

import '../core/theme/app_theme.dart';

class ThemeState extends Equatable {
  final AppThemeType themeType;

  const ThemeState({this.themeType = AppThemeType.system});

  @override
  List<Object> get props => [themeType];

  ThemeState copyWith({AppThemeType? themeType}) {
    return ThemeState(themeType: themeType ?? this.themeType);
  }
}
