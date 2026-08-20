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
`SearchService`, `QuizGenerator`, `PdfExportService`, `ShareImageService`,
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

## Project rules (from CONTRIBUTING.md / PRIVACY.md)

These are product commitments, not preferences:

- **No tracking, analytics, telemetry, ads, or paywalls, and the app itself makes no network
  requests.** Features are built around this: PDFs are generated on-device from bundled
  assets and citation URLs are copied to the clipboard rather than opened. The one hand-off
  outward is feedback, which `url_launcher` opens in WhatsApp (`ContactInfo.whatsappUri`)
  and falls back to the OS share sheet (`share_plus`) — the app never talks to a server
  itself, and the release APK still declares no `INTERNET` permission.
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

## Release / Android signing

Release signing reads `android/key.properties` (gitignored, never committed):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=../upload-keystore.jks
```

`rootProject.file("key.properties")` resolves to `android/key.properties`, and `storeFile` is
resolved relative to `android/app/`, so `../upload-keystore.jks` means
**`android/upload-keystore.jks`**. (`android/key.properties.example` documents a different
layout — `../app/upload-keystore.jks` → `android/app/upload-keystore.jks`; either works as
long as the two agree.) If `key.properties` is missing, the release build silently falls back
to debug signing — Play will reject that artifact, so verify the file exists before building.

Publishing checklist:

1. Bump `version:` in `pubspec.yaml` **and** `AppInfo.appVersion` in `constants.dart`; the
   Play versionCode is the `+N` suffix and must be strictly greater than any uploaded build.
2. Also update `CITATION.cff` and the README version badge.
3. `dart format --set-exit-if-changed` → `flutter analyze --fatal-warnings --fatal-infos` →
   `flutter test`.
4. `flutter build appbundle --release` (Play) and/or `flutter build apk --release --split-per-abi`.
5. Verify the shipped target SDK: `aapt2 dump badging build/app/outputs/flutter-apk/app-release.apk | grep targetSdk`.

Google Play requires `targetSdk = 36` (Android 16) for updates published after
**31 August 2026**; `compileSdk`/`targetSdk` are pinned to 36 in
[android/app/build.gradle.kts](android/app/build.gradle.kts) — pinned literally rather than
via `flutter.targetSdkVersion` so a Flutter downgrade cannot silently drop below the Play
floor. Toolchain: Flutter 3.47.1 / Dart 3.13.1, Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, JDK 17.

**Branding is generated, not hand-exported.** `assets/images/logo.png` and
`logo_foreground.png` come from a GDI+ script; `dart run flutter_launcher_icons`
turns them into launcher icons (including the adaptive + monochrome layers), and
the Android splash drawables (`drawable-*/splash.png`, `android12splash.png`) are
emitted at every density from the same emblem. Regenerate rather than editing the
PNGs by hand.

**The launch screen has two separate paths.** Pre-Android-12 uses
`drawable/launch_background.xml`; Android 12+ ignores that and uses
`windowSplashScreenBackground` / `windowSplashScreenAnimatedIcon` on `LaunchTheme`
in `values-v31`. `MainActivity` must keep `android:theme="@style/LaunchTheme"` —
pointing it at `NormalTheme` leaves the app with no launch screen *and* lets the
resource shrinker delete the splash drawables.

**Release builds behave differently from debug — always smoke-test the release APK on a
device before shipping.** `isMinifyEnabled` + `isShrinkResources` are on, and resource
shrinking drops any drawable that is only referenced by a *string* in Dart code. That is how
`@mipmap/ic_launcher` disappeared from release builds and made
`NotificationService.initialize()` throw; because `main()` awaited it before `runApp()`, the
app hung on the splash screen. Notification icons must use `@mipmap/launcher_icon` (the one
the manifest references, so the shrinker keeps it), and platform init in `main()` stays
wrapped in try/catch.

Reminders schedule with `AndroidScheduleMode.inexactAllowWhileIdle` on purpose: the exact
modes need `SCHEDULE_EXACT_ALARM`, which Android 13+ does not grant on install and Play
restricts to alarm-clock/calendar apps.

Build gotchas on Windows:

- Enable Developer Mode, or `flutter pub get` fails with *"Building with plugins requires
  symlink support"* (which then makes `flutter test` exit before running anything).
- `org.gradle.daemon=false` means each build spawns a single-use daemon. If a previous build
  is still running, the next one dies with *"Timeout waiting to lock build logic queue"* —
  wait for the stale `java.exe` to exit rather than re-running immediately.
- The Flutter migrator may append `android.builtInKotlin=false` / `android.newDsl=false` to
  `android/gradle.properties` on first build with a newer Flutter; keep those.
- `kotlin.jvm.target.validation.mode=warning` in `android/gradle.properties` is load-bearing:
  Flutter pins some plugin modules to Java 11 while others build at 17 and a few still declare
  Kotlin 1.8, and KGP 2.x makes that mismatch fatal. No single global JVM target satisfies
  every plugin — do not "fix" this by forcing one.
- The pinned NDK must actually be installed; AGP needs it to strip symbols even though the
  project has no native code. `sdkmanager --install "ndk;28.2.13676358"`.
- `flutter test`/`build` can quietly re-resolve `pubspec.lock` — check `git status` afterwards.
