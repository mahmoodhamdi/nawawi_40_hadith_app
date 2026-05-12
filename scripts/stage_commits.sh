#!/usr/bin/env bash
#
# Pre-stage the v1.4.0 work as a sequence of logical commits.
#
# Run this ONCE on a clean working branch (no other changes pending):
#
#   git checkout -b release/v1.4.0
#   bash scripts/stage_commits.sh
#   git log --oneline -20
#   # review, then push and open PR
#
# The script is idempotent in spirit but NOT idempotent in fact —
# re-running will produce empty commits or fail noisy. It's meant to be
# run once and then deleted (or kept as a reference).
#
# Each commit is small enough to review on GitHub without scrolling.
# Use `git rebase -i HEAD~N` if you want to fold or reorder.

set -euo pipefail

cd "$(dirname "$0")/.."

# ---- safety: refuse to run if we're not on a feature branch ----
current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
  echo "Refusing to run on $current_branch. Create a branch first:"
  echo "  git checkout -b release/v1.4.0"
  exit 1
fi

# ---- helper ----
commit() {
  local title="$1"
  if git diff --staged --quiet; then
    echo "  (nothing staged for: $title) — skipping"
    return
  fi
  git commit -m "$title"
}

# ============================================================================
# 1. chore: agent workspace setup
# ============================================================================
git add .gitignore
commit "chore: gitignore agent workspace"

# ============================================================================
# 2. feat(content): citation field on all 42 hadiths
# ============================================================================
git add assets/json/40-hadith-nawawi.json assets/json/40-hadith-nawawi-en.json
git add lib/models/hadith.dart test/models/hadith_test.dart
commit "feat(content): structured citation field for all 42 hadiths

Each hadith now carries narrator + collection + canonical sunnah.com URL
in both Arabic and English JSONs. Citation data cross-referenced against
the fawazahmed0/hadith-api Arabic mirror.

No Arabic hadith text was modified — see .agent/content_issues.md for
flagged typographic discrepancies that require human review."

# ============================================================================
# 3. feat(ui): citation card + notes editor + related-hadiths card
# ============================================================================
git add lib/widgets/hadith_citation_card.dart \
        lib/widgets/hadith_note_card.dart \
        lib/widgets/related_hadiths_card.dart
git add lib/screens/hadith_details_screen.dart
git add test/widgets/hadith_citation_card_test.dart \
        test/widgets/hadith_note_card_test.dart \
        test/widgets/related_hadiths_card_test.dart \
        test/models/hadith_topics_test.dart
commit "feat(ui): citation, notes, and related-hadiths cards in details screen"

# ============================================================================
# 4. feat(streaks): reading streaks cubit + home indicator + settings
# ============================================================================
git add lib/cubit/reading_streaks_cubit.dart lib/cubit/reading_streaks_state.dart
git add test/cubit/reading_streaks_cubit_test.dart
git add lib/cubit/notes_cubit.dart lib/cubit/notes_state.dart
git add test/cubit/notes_cubit_test.dart
git add lib/cubit/memorize_cubit.dart
git add test/cubit/memorize_cubit_test.dart
git add lib/cubit/quiz_cubit.dart lib/cubit/quiz_state.dart
git add lib/models/quiz_question.dart
git add lib/services/quiz_generator.dart
git add test/cubit/quiz_cubit_test.dart
git add test/services/quiz_generator_test.dart
git add lib/main.dart
commit "feat(cubits): reading streaks, notes, memorize mode, quiz mode"

# ============================================================================
# 5. feat(services): backup, feedback, pdf export, search service
# ============================================================================
git add lib/services/backup_service.dart \
        lib/services/feedback_service.dart \
        lib/services/pdf_export_service.dart \
        lib/services/search_service.dart \
        lib/services/notification_service.dart
git add test/services/backup_service_test.dart \
        test/services/feedback_service_test.dart \
        test/services/pdf_export_service_test.dart \
        test/services/search_service_test.dart
git add pubspec.yaml pubspec.lock
commit "feat(services): local backup, feedback, PDF export, smart search

Backup: SharedPreferences ↔ JSON via system share sheet; allowlisted keys,
schema-versioned, no cloud.

Feedback: share-sheet flow with non-identifying device-info block.

PDF export: single-hadith and full-collection rendering using \`pdf\`
+ \`printing\` packages, Cairo font embedded.

Search service: Arabic normalization + tatweel folding + light stemming
(prefix/suffix stripping) + Latin transliteration of ~80 common
Islamic terms + Levenshtein fuzzy matching."

# ============================================================================
# 6. feat(ui): settings screen + quiz screen + home polish
# ============================================================================
git add lib/screens/settings_screen.dart \
        lib/screens/quiz_screen.dart \
        lib/screens/home_screen.dart
git add lib/core/constants.dart \
        lib/core/l10n/app_localizations.dart \
        lib/core/theme/app_theme.dart \
        lib/core/theme/sepia_theme.dart \
        lib/services/share_image_service.dart
git add test/cubit/theme_cubit_test.dart
commit "feat(ui): settings sections, quiz screen, home streak chip, sepia theme

- Settings: streak card, notes count, backup export/import, feedback,
  quiz launch button.
- Quiz screen: 3-phase flow (intro → MCQ → results) with per-question
  review.
- Home: streak chip near the welcome banner.
- Sepia theme (5th palette) appended to AppThemeType for eye-care
  reading; placed last in the enum to preserve persisted indices.
- Share-image dialog: 3 layout templates (classic, minimalist, ornate)."

# ============================================================================
# 7. chore(assets): launcher icons + branded web manifest
# ============================================================================
git add android/app/src/main/res/mipmap-*/launcher_icon.png \
        android/app/src/main/res/mipmap-*/ic_launcher.png \
        android/app/src/main/res/mipmap-*/ic_launcher_round.png
git add ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-*.png
git add web/icons/Icon-*.png web/favicon.png
git add web/manifest.json web/index.html
git add web/robots.txt web/sitemap.xml web/opensearch.xml
commit "chore(assets): regenerate launcher icons + brand the web manifest + SEO

41 launcher icon variants regenerated from a single book+crescent
design (Android 5 densities, iOS 15 sizes, web 192/512/maskable +
favicon). Web manifest, index.html, robots.txt, sitemap.xml, and
opensearch.xml are all branded properly (previously placeholders)."

# ============================================================================
# 8. ci: GitHub Actions workflows
# ============================================================================
git add .github/workflows/analyze.yml \
        .github/workflows/test.yml \
        .github/workflows/build_android.yml \
        .github/workflows/build_web.yml \
        .github/workflows/release.yml
commit "ci: analyze + test + build (android/web) + release workflows"

# ============================================================================
# 9. docs: privacy, contributing, changelog, l10n, keystore, release notes
# ============================================================================
git add PRIVACY.md \
        CONTRIBUTING.md \
        CHANGELOG.md \
        CITATION.cff \
        README.md
git add docs/L10N_MIGRATION.md \
        docs/KEYSTORE_SETUP.md \
        docs/RELEASE_1.4.0.md
git add android/key.properties.example
git add assets/l10n/intl_ar.arb assets/l10n/intl_en.arb
commit "docs: privacy, contributing, changelog, l10n plan, keystore guide"

# ============================================================================
# 10. chore(repo): issue/PR templates, CODEOWNERS, funding stub
# ============================================================================
git add .github/CODEOWNERS \
        .github/FUNDING.yml \
        .github/PULL_REQUEST_TEMPLATE.md \
        .github/ISSUE_TEMPLATE/bug_report.yml \
        .github/ISSUE_TEMPLATE/content_issue.yml \
        .github/ISSUE_TEMPLATE/feature_request.yml
commit "chore(repo): issue + PR templates, CODEOWNERS, FUNDING stub"

# ============================================================================
# 11. marketing: dawah kit + 94 social graphics + sample PDF + QR codes
# ============================================================================
git add marketing/
commit "marketing(dawah): store listings, 94 social graphics, QR codes, sample PDF

- Play / App Store / Huawei / F-Droid listings in AR + EN + ID + UR
- DAWAH_PLAN.md (6-month roadmap, 100K-download target)
- 42 hadith square cards (1080×1080) + 42 stories (1080×1920)
- 10 promo cards (5 designs × 2 sizes)
- 7 branded QR codes per distribution channel
- Sample one-hadith PDF using the same brand language
- Mosque outreach kit: A4 poster spec, khateeb scripts (AR + EN),
  WhatsApp templates, influencer kit"

# ============================================================================
# 12. chore(version): bump to 1.4.0+10
# ============================================================================
# (this catches any straggler — should be empty if the above covered everything)
git add linux/flutter/generated_plugin_registrant.cc \
        linux/flutter/generated_plugins.cmake \
        macos/Flutter/GeneratedPluginRegistrant.swift 2>/dev/null || true
git add -A 2>/dev/null
commit "chore(version): bump to v1.4.0+10 + generated platform plugin registrants"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "=============================================="
echo "Done. Commits staged:"
git log --oneline "$(git merge-base HEAD main 2>/dev/null || git rev-list --max-parents=0 HEAD | head -1)..HEAD" 2>/dev/null \
  || git log --oneline -20
echo ""
echo "Review with:"
echo "  git log --stat --oneline"
echo "  git show <hash>"
echo "Then push:"
echo "  git push -u origin $current_branch"
echo "And open a PR."
