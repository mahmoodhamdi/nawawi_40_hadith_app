# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Feedback now opens WhatsApp directly, addressed to the maintainer with a
  short header prefilled, instead of an in-app compose dialog feeding a
  generic share sheet where nothing obvious happened. The user writes the note
  where they are going to send it from. The share sheet remains the fallback
  when WhatsApp cannot be opened, and the app still sends nothing itself — the
  message only leaves the device when the user presses send.

### Removed
- Settings no longer carries the backup/restore card or the About card. The
  app is small enough that neither earned its space; `BackupService` is left
  in place but is no longer reachable from the UI.

## [1.5.0] - 2026-08-20 — "Android 16 Compliance"

### Added
- Per-hadith topic tags (37 distinct topics, conservatively curated)
- "Related hadiths" card on the details screen, surfaces hadiths sharing
  at least one topic tag
- Friday (Jumu'ah) recurring reminder schedule, separate from the daily
  reminder
- Five approximate prayer-time anchors (Fajr / Dhuhr / Asr / Maghrib /
  Isha) for use as quick reminder presets — no GPS or city DB needed
- Search service with Latin → Arabic transliteration for ~80 common
  Islamic terms (`niyyah` → `نية`, `bukhari` → `بخاري`, etc.) and
  Levenshtein fuzzy matching for queries ≥ 4 characters
- Launcher icons regenerated for Android (5 densities), iOS (15 sizes),
  and Web (192 / 512 / maskable / favicon) from a single clean source
- CONTRIBUTING.md + CHANGELOG.md

### Fixed
- **App could not start at all in release builds.** `main()` awaited
  `NotificationService.initialize()` before `runApp()`, and the plugin threw
  `PlatformException(invalid_icon)` because the notification icon referenced
  `@mipmap/ic_launcher` while the app actually ships `@mipmap/launcher_icon`
  (resource shrinking drops the unreferenced one). The result was a splash
  screen that never advanced. The icon now points at the resource that ships,
  and notification setup is wrapped so a reminder failure can never stop the
  app from opening.
- **Daily and Friday reminders never scheduled on Android 13+.** Both used
  `AndroidScheduleMode.exactAllowWhileIdle`, which requires the
  `SCHEDULE_EXACT_ALARM` permission that Android 13+ does not grant on
  install; every attempt failed with `exact_alarms_not_permitted` and the
  settings toggle silently flipped back. Reminders now schedule inexactly,
  which needs no special permission.
- **Reminder time picker showed a blank coloured block instead of the selected
  hour.** The picker set only `hourMinuteTextColor` to the primary colour while
  the selected field is *filled* with that same colour, so the digits were
  invisible. Selected and unselected states now get explicit, contrasting
  colours.
- Settings screen: the "Notes" card rendered as a bare title with no content
  and nothing to tap whenever there were no notes yet. It now explains how to
  add one.
- **The app had no launch screen at all.** `MainActivity` pointed straight at
  `NormalTheme`, so `LaunchTheme` was never applied — Android showed its own
  default while the engine started, and the resource shrinker stripped the
  splash drawables as unreferenced. The activity now uses `LaunchTheme`, which
  paints the app's own green ground on every API level.
- **`values/styles.xml` was missing entirely.** `LaunchTheme` existed only under
  `values-night` and `values-v31`, so a device on API 24–30 in light mode had
  no matching resource to resolve.
- The audio player inside focused reading was a separate, trimmed-down copy that
  had quietly lost replay, playback speed, the loading state and the
  accessibility labels. Both screens now use the one `AudioPlayerWidget`.
- Playback-speed cycling skipped 0.5x, 0.75x and 1.25x — it hopped 1.0 → 1.5 →
  2.0 and ignored `AudioConstants.playbackSpeedOptions`.
- The player's progress semantics divided by a zero duration (NaN, and
  `NaN.round()` throws) before a clip reported its length.
- Tapping a reminder notification left the user wherever they were instead of
  opening the hadith the notification named. The reminder's payload is now
  routed to the details screen, including when the notification cold-starts
  the app.

### Changed
- **Target SDK raised to Android 16 (API 36)** — required by Google Play
  for app updates published after 31 August 2026. `compileSdk` and
  `targetSdk` are both 36; no new permissions were added.
- Home-screen search now uses `SearchService.matches`, expanding hits to
  titles, topic labels, citation narrator, and source collection
- `Hadith` model now stores `topicLabelsAr` + `topicLabelsEn` separately
  (the previous single `topicLabels` field defaulted to whichever JSON
  loaded last — buggy for bilingual rendering)
- **New app mark, launcher icon and splash screen.** The icon is a gold Rub el
  Hizb holding the Arabic-Indic ٤٠ on a deep green ground, generated from
  source (`scripts/`-style GDI+ drawing) rather than hand-exported, with an
  Android adaptive icon (separate foreground/background plus a monochrome
  layer for themed icons) and a matching splash on both the pre-12 layer-list
  and the Android 12+ `windowSplashScreenAnimatedIcon` path.
- **All dependencies upgraded to their latest versions**, including the two
  majors that were previously held back: `flutter_local_notifications`
  18 → 22.3 (every method moved to named parameters and
  `UILocalNotificationDateInterpretation` was removed) and `flutter_timezone`
  3 → 5.1 (`getLocalTimezone()` now returns a `TimezoneInfo` rather than a
  string). `timezone` went 0.10 → 0.11 and `share_plus` 12 → 13.
- **Focused reading mode now follows the app's theme.** It painted a
  hard-coded navy gradient with gold accents on a black scaffold regardless
  of the selected theme, so it looked like a different app. Every colour is
  now derived from the active `ThemeData`, so light, dark, blue, purple and
  sepia each get a reader that matches. Reading itself was tuned too: a
  620px measure so lines stay readable on tablets, looser line height, long
  narrations justified instead of centred, and a slim rule-and-diamond
  ornament in place of the flat gold bar.
- **Settings screen reworked.** The seven equally-weighted cards are now
  grouped under four headings (Preferences / Your journey / Your data /
  About); backup actions are stacked full-width instead of two cramped pills
  that wrapped their labels; primary buttons are consistently full-width; the
  language rows dropped a redundant check icon next to the radio; and a new
  About card shows the app version, reciter, and licence — the version was
  previously only embedded in feedback reports with no way to read it.
- Toolchain updated to Flutter 3.47.1 / Dart 3.13.1, Gradle 9.3.1,
  Android Gradle Plugin 9.1.0, Kotlin 2.4.0, Java 17. `aaptOptions` and
  `kotlinOptions` were replaced with their AGP 9 equivalents
  (`androidResources`, top-level `kotlin { compilerOptions }`)

### Removed
- `SCHEDULE_EXACT_ALARM` permission — no longer needed now that reminders
  schedule inexactly, and Google Play restricts it to alarm-clock and
  calendar apps.

### Notes
- No new permissions
- No new tracking / analytics
- No Arabic hadith text was modified

## [1.4.0] - 2026-05-12 — "Dawah Expansion"

### Added
- **Content integrity**: structured `citation` field on all 42 hadiths
  (narrator + collection + sunnah.com URL) in both AR and EN
- **`HadithCitation`** model + bilingual `HadithCitationCard` widget on
  the details screen; tapping the URL row copies it to clipboard
  (no `url_launcher` dep, preserving offline-first guarantee)
- **Reading Streaks** — `ReadingStreaksCubit` tracks consecutive-day
  reading streak; gentle istiqamah framing, no gamification
- **Per-hadith Notes** — markdown notes per hadith, edited from details
  screen, persisted locally; included in backup exports
- **Memorize Mode** — hide-and-reveal for memorization, toggle in AppBar
- **Quiz Mode** — 10-question MCQ sessions (narrator / collection /
  excerpt-to-number), seeded Random for deterministic tests
- **Local Backup / Restore** — `BackupService` exports SharedPreferences
  as JSON via share sheet; imports via paste dialog. Schema-versioned,
  allowlisted keys
- **In-app Feedback** — `FeedbackService` opens system share sheet with
  pre-filled body + non-identifying device info
- **PDF Export** — single hadith or full collection as PDF with cover
  page, Cairo font embedded (`pdf` + `printing` deps added)
- **Sepia Theme** — 5th theme variant with warm parchment palette,
  WCAG AA contrast
- **Multi-template share cards** — three layouts: classic, minimalist,
  ornate (Quranic manuscript style)
- **Streak indicator on home screen** — shows current streak chip when
  > 0; taps navigate to settings
- **5 GitHub Actions workflows**: analyze, test, build_android,
  build_web, release (with 75% line-coverage gate)
- **94 social media graphics**:
  - 42 hadith square cards (1080×1080)
  - 42 hadith story cards (1080×1920)
  - 10 app promo cards (5 designs × square + story)
- **Marketing kit** (`marketing/`): store listings × 4 languages × 4
  stores; DAWAH_PLAN.md; mosque-outreach kit; influencer kit
- **PRIVACY.md** rewritten bilingual, accurate (was a stub misstating
  permissions)
- **Localization scaffolding**: 94 strings auto-extracted to ARB files
  for `en` + `ar`; `docs/L10N_MIGRATION.md` plan for the ARB migration

### Changed
- `Hadith.fromJson` now optional-parses the `citation` field
- Bumped to Flutter `^3.8.0` baseline (was already there)
- README badges updated (300+ tests, offline 100%, no tracking, etc.)

### Verified
- Per-collection attribution cross-referenced for all 42 hadiths against
  the canonical Imam an-Nawawi text and the
  `uthumany/nawawi-40-hadiths` reference repo
- `sunnah.com` direct text diff was not performed because sunnah.com
  was unreachable from the development network — flagged for future
  human review

### Privacy guarantees preserved
- ✅ Zero personal data collected
- ✅ Zero analytics / tracking SDKs
- ✅ Zero new permissions
- ✅ Zero internet calls from the app
- ✅ Zero Arabic hadith text modifications

## [1.3.0] - 2024-Q4

### Added
- Hadith titles displayed in UI alongside body
- Markdown-formatted explanations
- Improved RTL support for Arabic

See `docs/RELEASE_1.3.0.md` for the full notes of this release.

## [1.2.1] - 2024

See `docs/RELEASE_1.2.1.md`.

## [1.2.0] - 2024

### Added
- English language support and bilingual UI
- Search by hadith number with history
- Daily reminder notifications

## Older

Earlier history exists in `git log` but is not retroactively reformatted
into this changelog.

---

[Unreleased]: https://github.com/mahmoodhamdi/nawawi_40_hadith_app/compare/v1.4.0...HEAD
[1.4.0]: https://github.com/mahmoodhamdi/nawawi_40_hadith_app/releases/tag/v1.4.0
[1.3.0]: https://github.com/mahmoodhamdi/nawawi_40_hadith_app/releases/tag/v1.3.0
[1.2.1]: https://github.com/mahmoodhamdi/nawawi_40_hadith_app/releases/tag/v1.2.1
[1.2.0]: https://github.com/mahmoodhamdi/nawawi_40_hadith_app/releases/tag/v1.2.0
