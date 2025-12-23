# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter Islamic app displaying the Forty Nawawi Hadiths with audio recitation by Sheikh Ahmad Al-Nafees. The app is fully offline-first with bilingual support (Arabic/English) and RTL layout handling.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run all tests (269 tests)
flutter test

# Run a single test file
flutter test test/cubit/hadith_cubit_test.dart

# Run integration tests
flutter test integration_test/app_test.dart

# Build release APK
flutter build apk --release

# Analyze code
flutter analyze

# Format code
dart format lib/
```

## Architecture

### State Management (BLoC/Cubit Pattern)
The app uses `flutter_bloc` with Cubit pattern. All cubits are provided at root level in `main.dart` via `MultiBlocProvider`:

| Cubit | Responsibility |
|-------|---------------|
| **HadithCubit** | Loads hadiths from JSON, manages hadith list state |
| **AudioPlayerCubit** | Audio playback using `just_audio` (play/pause, seek, speed) |
| **ThemeCubit** | Theme switching (light, dark, blue, purple, system) |
| **FontSizeCubit** | Font size preferences |
| **LastReadCubit** | Tracks last read hadith for resume |
| **FavoritesCubit** | Favorites/bookmarks management |
| **ReadingStatsCubit** | Reading progress statistics |
| **ReminderCubit** | Daily notification reminders |
| **SearchHistoryCubit** | Recent search queries history |
| **LanguageCubit** | Language switching (AR/EN) with RTL/LTR handling |

### Data Flow
1. Hadiths loaded from `assets/json/40-hadith-nawawi.json` (Arabic) and `assets/json/40-hadith-nawawi-en.json` (English) via `HadithLoader`
2. Audio files: `assets/audio/audio_{index}.mp3` (42 files)
3. User preferences persisted via `PreferencesService` using `shared_preferences`

### Bilingual/Localization System
- **LanguageCubit** (`lib/cubit/language_cubit.dart`): Manages `AppLanguage` enum (arabic/english)
- **AppLocalizations** (`lib/core/l10n/app_localizations.dart`): All UI strings with `isArabic` conditional returns
- **Hadith model**: Bilingual fields (`titleAr`/`titleEn`, `hadithAr`/`hadithEn`, `descriptionAr`/`descriptionEn`) with `getTitle(languageCode)` helpers
- RTL/LTR handled via `Directionality` widget wrapping `MaterialApp` based on `languageState.textDirection`

### Theming System
Located in `lib/core/theme/`:
- `app_theme.dart`: Central theme configuration with `AppThemeType` enum
- Individual files: `light_theme.dart`, `dark_theme.dart`, `blue_theme.dart`, `purple_theme.dart`
- Uses Cairo font family for Arabic text

### Key Services
- **HadithLoader** (`lib/services/hadith_loader.dart`): Loads bilingual hadith data from bundled JSON
- **PreferencesService** (`lib/services/preferences_service.dart`): SharedPreferences wrapper for user settings
- **NotificationService** (`lib/services/notification_service.dart`): Daily reminder notifications using `flutter_local_notifications`
- **ShareImageService** (`lib/services/share_image_service.dart`): Generate shareable hadith images

## Testing

Tests use `bloc_test` and `mocktail` packages:

```
test/
├── cubit/              # Cubit unit tests (all cubits)
├── models/             # Hadith model tests
├── services/           # Service unit tests
└── widget_test.dart    # Widget tests

integration_test/
└── app_test.dart       # E2E integration tests
```

## Important Conventions

- Bilingual app with RTL (Arabic) / LTR (English) layout support
- Audio files must be named `audio_{hadith_index}.mp3`
- JSON data: Arabic at `assets/json/40-hadith-nawawi.json`, English at `assets/json/40-hadith-nawawi-en.json`
- Uses `responsive_framework` for adaptive layouts across device sizes
- All new features require unit and integration tests before merge
