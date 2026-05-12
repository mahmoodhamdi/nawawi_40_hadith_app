# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

### Changed
- Home-screen search now uses `SearchService.matches`, expanding hits to
  titles, topic labels, citation narrator, and source collection
- `Hadith` model now stores `topicLabelsAr` + `topicLabelsEn` separately
  (the previous single `topicLabels` field defaulted to whichever JSON
  loaded last — buggy for bilingual rendering)

### Notes
- No new permissions
- No new tracking / analytics
- No Arabic hadith text was modified
- Display-only typo fix log: `.agent/content_issues.md`

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
