/// Application-wide constants
///
/// This file centralizes all magic numbers and configurable values
/// to improve maintainability and consistency across the app.
library;

/// Constants related to audio playback
class AudioConstants {
  AudioConstants._();

  /// Duration to skip forward/backward in seconds
  static const int skipDurationSeconds = 10;

  /// Skip duration as Duration object
  static const Duration skipDuration = Duration(seconds: skipDurationSeconds);

  /// Default playback speed
  static const double defaultPlaybackSpeed = 1.0;

  /// Available playback speed options
  static const List<double> playbackSpeedOptions = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    2.0,
  ];

  /// Minimum playback speed
  static const double minPlaybackSpeed = 0.5;

  /// Maximum playback speed
  static const double maxPlaybackSpeed = 2.0;
}

/// Constants related to font sizes
class FontSizeConstants {
  FontSizeConstants._();

  /// Default font size for hadith text
  static const double defaultHadithFontSize = 18.0;

  /// Default font size for description text
  static const double defaultDescriptionFontSize = 16.0;

  /// Minimum allowed font size
  static const double minFontSize = 12.0;

  /// Maximum allowed font size
  static const double maxFontSize = 30.0;

  /// Step size for font adjustment
  static const double fontSizeStep = 2.0;
}

/// Constants related to search functionality
class SearchConstants {
  SearchConstants._();

  /// Debounce duration for search input
  static const Duration debounceDuration = Duration(milliseconds: 300);
}

/// Constants related to UI and layout
class UIConstants {
  UIConstants._();

  /// Border radius for cards
  static const double cardBorderRadius = 16.0;

  /// Border radius for search field
  static const double searchFieldBorderRadius = 30.0;

  /// Default padding
  static const double defaultPadding = 16.0;

  /// Small padding
  static const double smallPadding = 8.0;

  /// Large padding
  static const double largePadding = 24.0;
}

/// Constants related to data validation
class ValidationConstants {
  ValidationConstants._();

  /// Minimum valid hadith index (1-based)
  static const int minHadithIndex = 1;

  /// Maximum valid hadith index (safe upper bound)
  static const int maxHadithIndex = 100;

  /// Minimum valid theme index
  static const int minThemeIndex = 0;

  /// Maximum valid theme index
  static const int maxThemeIndex = 10;
}

/// Constants related to SharedPreferences keys
class PreferenceKeys {
  PreferenceKeys._();

  /// Key for storing last read hadith index
  static const String lastReadHadith = 'last_read_hadith';

  /// Key for storing last read timestamp
  static const String lastReadTime = 'last_read_time';

  /// Key for storing theme preference
  static const String theme = 'app_theme';

  /// Key for storing hadith font size
  static const String hadithFontSize = 'hadith_font_size';

  /// Key for storing description font size
  static const String descriptionFontSize = 'description_font_size';

  /// Key for storing favorite hadiths
  static const String favorites = 'favorite_hadiths';

  /// Key for storing read hadiths
  static const String readHadiths = 'read_hadiths';

  /// Key for storing reminder enabled state
  static const String reminderEnabled = 'reminder_enabled';

  /// Key for storing reminder hour
  static const String reminderHour = 'reminder_hour';

  /// Key for storing reminder minute
  static const String reminderMinute = 'reminder_minute';
}

/// Constants related to assets
class AssetPaths {
  AssetPaths._();

  /// Path to hadith JSON data file
  static const String hadithJson = 'assets/json/40-hadith-nawawi.json';

  /// Path pattern for audio files (use with index)
  static String audioFile(int index) => 'assets/audio/audio_$index.mp3';

  /// Path to fonts directory
  static const String fontsDir = 'assets/fonts/';

  /// Path to images directory
  static const String imagesDir = 'assets/images/';
}
