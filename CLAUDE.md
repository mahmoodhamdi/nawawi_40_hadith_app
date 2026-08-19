# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app presenting the 40 Hadith Nawawi (42 entries in practice) in Arabic + English
with audio narration. **Fully offline: the app makes no network requests at all, has no
backend, no analytics, and no account system.** Package name `hadith_nawawi_audio`,
applicationId `com.ashwah.hadith_nawawi_audio`.

## Commands

```bash
flutter pub get

# What CI enforces (.github/workflows/analyze.yml + test.yml)
dart format --output=none --set-exit-if-changed lib/ test/ integration_test/
flutter analyze --fatal-warnings --fatal-infos
flutter test --coverage --reporter=expanded      # coverage floor: 25% lines, or CI fails

# Single file / single test
flutter test test/services/search_service_test.dart
flutter test test/cubit/quiz_cubit_test.dart --plain-name "starts a session"

flutter test integration_test/app_test.dart -d <device>   # needs a real device/emulator

flutter build apk --release --split-per-abi
flutter build appbundle --release
flutter build web --release --pwa-strategy=offline-first --base-href "/nawawi_40_hadith_app/"
```

**Windows:** `flutter test` and any build fail with *"Building with plugins requires symlink
support"* unless Developer Mode is enabled (`start ms-settings:developers`). Android release
builds need JDK 17.

Running `flutter test` may rewrite `pubspec.lock` via an implicit `pub get` — check
`git status` and revert it if the lock bump wasn't intended.

## Architecture

**State: `flutter_bloc` Cubits only.** No Riverpod/Provider/GetX — this is a hard project
rule. Every cubit is registered globally in `MultiBlocProvider` in [main.dart](lib/main.dart);
there is no DI container and no routing package (screens use `Navigator.push` directly).
Cubits load their own persisted state in their constructor and write through to
`SharedPreferences` on every mutation. States are `Equatable` with `copyWith`.

**Services are stateless static-method classes** (`HadithLoader`, `PreferencesService`,
`SearchService`, `QuizGenerator`, `BackupService`, `PdfExportService`, `ShareImageService`,
`NotificationService`, `FeedbackService`). `SearchService` and `QuizGenerator` are pure — no
Flutter or I/O imports — which is why they are directly unit-testable; `QuizGenerator` takes
an injectable `Random` so tests can pin a seed.

**Data flow.** `HadithLoader.loadHadiths()` reads `assets/json/40-hadith-nawawi.json`
(Arabic, required) and `40-hadith-nawawi-en.json` (English, optional) and merges them
**positionally by list index** into one bilingual `Hadith` per entry. English falls back to
Arabic field-by-field when absent. `Hadith.getTitle/getHadith/getDescription(languageCode)`
select the language at render time — there is only ever one hadith list in memory.
Descriptions are Markdown, rendered with `flutter_markdown`.

**Index convention: hadith indices are 1-based everywhere outside the list itself.** Stored
prefs, `ValidationConstants.minHadithIndex..maxHadithIndex`, quiz answers, and
`AssetPaths.audioFile(i)` → `assets/audio/audio_$i.mp3` (files `audio_1`…`audio_42`) all use
the 1-based number. Only `List<Hadith>` access is 0-based.

**Localization is hand-written, not `gen-l10n`.** [app_localizations.dart](lib/core/l10n/app_localizations.dart)
is a class of `isArabic ? 'ع' : 'en'` ternary getters, obtained via
`AppLocalizations.of(context)` (watches `LanguageCubit`) or `.read(context)`. Text direction
comes from a `Directionality` widget driven by `LanguageCubit` in `main.dart`, **not** from
the `MaterialApp` locale. `assets/l10n/intl_{ar,en}.arb` are unused starter artifacts for a
planned ARB migration (see [docs/L10N_MIGRATION.md](docs/L10N_MIGRATION.md)); there is no
`l10n.yaml`. `lib/core/strings.dart` is dead legacy Arabic-only code with no callers.

**Topics power "related hadiths":** each JSON entry carries stable snake_case `topic_ids`
plus localized `topics` labels; two hadiths are "related" when their `topicIds` intersect.

### Persistence invariants

- All persisted keys live in `PreferenceKeys` in [constants.dart](lib/core/constants.dart) —
  except `LanguageCubit`, which uses its own private `'app_language'` key.
- `AppThemeType` in [app_theme.dart](lib/core/theme/app_theme.dart) is persisted as its
  **integer enum index**. Never reorder existing values; append new themes at the end
  (`AppTheme.themeTypes` controls display order independently).
- `AppInfo.appVersion` in `constants.dart` duplicates `version:` in `pubspec.yaml` on purpose
  (avoids a `package_info_plus` dependency) — bump both together.
- `BackupService.allowedKeys` is an allowlist for local JSON export/import; a new persisted
  key is not backed up until it is added there, and `schemaVersion` gates restore.

## Project rules (from CONTRIBUTING.md / PRIVACY.md)

These are product commitments, not preferences:

- **No tracking, analytics, telemetry, ads, paywalls, or network calls.** Features are built
  around this: feedback and backup go through the OS share sheet (`share_plus`), citation
  URLs are copied to the clipboard rather than opened (no `url_launcher`), PDFs are generated
  on-device from bundled assets.
- **No new dependencies without justification**; no new platform permissions without an
  explanation in the PR.
- **Arabic hadith text in `assets/json/` is not edited** without a canonical printed source
  or sunnah.com evidence; changes there need two reviewers, one a native Arabic speaker.
- **No gamification language** in user-facing strings ("XP", "level up", "achievement").
  Streaks use gentle istiqamah framing (استمرارية / مراجعة / تذكير).
- Tests are required for new cubits, services, and pure functions.

## Conventions

- Conventional Commits (`feat(quiz): ...`); branches `feat/…`, `fix/…`, `docs/…`,
  `content/…`, `chore/…`.
- **Commit messages must not mention coding assistants** — no `Co-Authored-By: Claude`,
  no "generated with" trailers. This repository's CONTRIBUTING.md explicitly forbids them.
- Tests use `SharedPreferences.setMockInitialValues({})` in `setUp`; `bloc_test` and
  `mocktail` are available dev dependencies.
- User-visible strings must be added to `AppLocalizations` in both languages, never inlined.
