# Localization Migration Plan: hardcoded ternaries → standard ARB

## Current state

The app uses **hardcoded ternary localization** in `lib/core/l10n/app_localizations.dart`:

```dart
String get appTitle => isArabic ? 'الأربعون النووية' : 'Forty Hadith Nawawi';
```

This works for 2 languages but **does not scale**:
- Adding a 3rd language means changing every getter to a switch/map
- No tooling support (no `flutter gen-l10n`)
- No build-time validation of missing keys
- Pluralization and gender are awkward
- Translators need to read Dart code

## Why migrate now

The da'wah distribution plan (`marketing/DAWAH_PLAN.md`) targets Indonesian
(230M+ Muslims), Urdu (200M+), Turkish (80M+), Bengali (160M+) etc. as
priority locales. Adding any of these without ARB migration is technically
debt-creating.

## The plan (estimated effort: 2-3 days of focused work)

### Step 1 — Adopt Flutter's standard l10n tooling

```yaml
# pubspec.yaml (under dev_dependencies)
dev_dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.0  # already implicitly present
```

```yaml
# Create l10n.yaml at repo root:
arb-dir: assets/l10n
template-arb-file: intl_en.arb
output-localization-file: app_localizations_gen.dart
output-class: AppLocalizationsGen
synthetic-package: false
output-dir: lib/core/l10n/gen
```

### Step 2 — Use the already-extracted starter ARB files

This session has produced:
- `assets/l10n/intl_en.arb` — 94 EN strings extracted
- `assets/l10n/intl_ar.arb` — 94 AR strings extracted

Review these files. They were extracted automatically from the existing
hardcoded ternaries. Some may need cleanup (verify newlines and
placeholders look right).

### Step 3 — Run generator + replace AppLocalizations

```bash
flutter gen-l10n
```

This produces `lib/core/l10n/gen/app_localizations_gen.dart`. Then:
- Rename old `AppLocalizations` class to `AppLegacy` (or delete it)
- Update `main.dart` to use the generated class:

```dart
MaterialApp(
  localizationsDelegates: AppLocalizationsGen.localizationsDelegates,
  supportedLocales: AppLocalizationsGen.supportedLocales,
  // ...
)
```

- Update every `AppLocalizations.of(context).foo` to
  `AppLocalizationsGen.of(context)!.foo`

This is a mechanical rename — `sed -i` or IDE find-and-replace handles 90%.

### Step 4 — Add new language ARBs

For each new language, create:
- `assets/l10n/intl_<code>.arb` (e.g., `intl_id.arb`, `intl_ur.arb`)
- Copy the structure from `intl_en.arb`
- Translate values — **use native speakers, not auto-translation**

Priority order (highest-impact first):
1. **Indonesian** (`id`) — sourced from a native speaker via Reddit
   r/MuslimDevelopers, IndonesianMuslimDev Telegram, or
   Pondok Pesantren tech contacts
2. **Urdu** (`ur`) — South Asian Muslim communities online
3. **Turkish** (`tr`) — Turkish Muslim developer community
4. **French** (`fr`) — for Maghreb + West Africa
5. **Bengali** (`bn`) — for Bangladesh + India

### Step 5 — Font fallbacks per language

The current `pubspec.yaml` bundles Cairo (great for Arabic). New scripts
need additional fonts. Add only the weights actually used to keep APK size
controlled:

| Language | Script | Font (Google Fonts) | Variants | Approx. size |
|---|---|---|---|---|
| Indonesian | Latin | (system) | — | 0 |
| Urdu | Nasta'liq | Noto Nastaliq Urdu | Regular, Bold | ~300 KB |
| Turkish | Latin | (system) | — | 0 |
| Bengali | Bengali | Noto Sans Bengali | Regular, Bold | ~250 KB |
| French | Latin | (system) | — | 0 |
| Persian | Farsi | Vazirmatn | Regular, Bold | ~150 KB |

Add via `pubspec.yaml` `fonts:` section, conditionally loaded per locale
in `app_theme.dart`.

### Step 6 — RTL handling

Locales requiring RTL: `ar`, `ur`, `fa`, `he`, `ps`.
The existing `LanguageCubit` already supports `textDirection` switching;
just extend the `AppLanguage` enum.

```dart
enum AppLanguage {
  arabic(code: 'ar', dir: TextDirection.rtl),
  english(code: 'en', dir: TextDirection.ltr),
  indonesian(code: 'id', dir: TextDirection.ltr),
  urdu(code: 'ur', dir: TextDirection.rtl),
  // ...
}
```

### Step 7 — Hadith content translations

**These are NOT in the ARB files.** UI strings ≠ hadith content. The
hadith translations themselves must come from authoritative sources, not
auto-translation or volunteer effort without scholar review.

Existing translation sources to consider:
- sunnah.com has Nawawi40 in: English, Indonesian (Bahasa Indonesia),
  Turkish, Urdu. These can be pulled and verified.
- For French: use translations by Imam Yahya Sergio Yahe Pallavicini or
  Maison d'Ennour publications
- For Bengali: Ahle Hadeeth Bangla publications

Each translation must be:
- Sourced from a named, scholarly translator
- Stored in `assets/json/40-hadith-nawawi-<code>.json`
- Cited in `.agent/content_verification.md`

## Acceptance criteria

- [ ] `flutter gen-l10n` produces no warnings
- [ ] All hardcoded ternaries replaced with generated lookups
- [ ] Adding a new language = adding one `.arb` file (zero Dart code change)
- [ ] No hardcoded user-facing strings remain (verify with regex grep)
- [ ] Each new language displays without overflow or missing glyphs
- [ ] RTL languages render correctly
- [ ] All existing tests pass after migration
- [ ] Integration test added: cycle through every locale, walk every screen

## Risks

- **Big-bang migration is risky**. Suggest doing it in one focused PR
  rather than incrementally. Once started, finish in one sitting.
- **Font fallback misses**: a missing glyph renders as `□`. Test on real
  devices, not just emulator.
- **Right-to-left bugs**: a screen that "works" in Arabic may have subtle
  bugs in Urdu because Urdu Nastaliq has different baseline. Test both.
- **Translation quality drift**: don't accept volunteer translations
  without a second native-speaker review.

## Starter artifacts in this PR

- `assets/l10n/intl_en.arb` — 94 EN strings, ready
- `assets/l10n/intl_ar.arb` — 94 AR strings, ready

Both files are JSON, can be opened in any text editor. **No code changes
to the runtime have been made** — the migration itself is left for the
follow-up session that has Flutter installed and can run `flutter
gen-l10n` + verify.
