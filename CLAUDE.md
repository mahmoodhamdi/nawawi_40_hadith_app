# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter Islamic app displaying the Forty Nawawi Hadiths with audio recitation by Sheikh Ahmad Al-Nafees. The app is fully offline-first with Arabic RTL support.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Build release APK
flutter build apk --release

# Analyze code
flutter analyze
```

## Architecture

### State Management (BLoC/Cubit Pattern)
The app uses `flutter_bloc` with Cubit pattern for state management. All cubits are provided at the root level in `main.dart` via `MultiBlocProvider`:

- **HadithCubit** (`lib/cubit/hadith_cubit.dart`): Loads hadiths from JSON, manages hadith list state
- **AudioPlayerCubit** (`lib/cubit/audio_player_cubit.dart`): Manages audio playback using `just_audio`, handles play/pause, seek, and playback speed
- **ThemeCubit** (`lib/cubit/theme_cubit.dart`): Manages theme switching (light, dark, blue, purple, system)
- **FontSizeCubit** (`lib/cubit/font_size_cubit.dart`): Manages font size preferences
- **LastReadCubit** (`lib/cubit/last_read_cubit.dart`): Tracks last read hadith for resume functionality

### Data Flow
1. Hadiths are loaded from `assets/json/40-hadith-nawawi.json` via `HadithLoader` service
2. Audio files follow naming convention: `assets/audio/audio_{index}.mp3`
3. User preferences (theme, last read, font size) are persisted via `PreferencesService` using `shared_preferences`

### Theming System
Located in `lib/core/theme/`:
- `app_theme.dart`: Central theme configuration with `AppThemeType` enum
- Individual theme files: `light_theme.dart`, `dark_theme.dart`, `blue_theme.dart`, `purple_theme.dart`
- Uses Cairo font family for Arabic text

### Key Services
- **HadithLoader** (`lib/services/hadith_loader.dart`): Loads hadith data from bundled JSON
- **PreferencesService** (`lib/services/preferences_service.dart`): Handles SharedPreferences for user settings

## Project Structure

```
lib/
├── main.dart              # App entry, MultiBlocProvider setup
├── core/
│   ├── strings.dart       # Centralized Arabic strings
│   └── theme/             # Theme definitions
├── cubit/                 # State management (Cubit classes + states)
├── models/
│   └── hadith.dart        # Hadith data model
├── screens/
│   ├── home_screen.dart   # Hadith list view
│   └── hadith_details_screen.dart  # Single hadith with audio
├── services/              # Data loading and preferences
└── widgets/               # Reusable UI components
```

## Important Conventions

- App is Arabic-only with RTL layout (`locale: const Locale('ar')`)
- Audio files must be named `audio_{hadith_index}.mp3`
- JSON hadith data at `assets/json/40-hadith-nawawi.json`
- Uses `responsive_framework` for adaptive layouts across device sizes
