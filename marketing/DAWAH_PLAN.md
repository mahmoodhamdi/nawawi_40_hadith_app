# خطة الدعوة | Da'wah Distribution Plan

> اللهم اجعله صدقة جارية لمصممه ومطوّره وكل من شارك في نشره ولمن استفاد منه.

This plan is a 6-month roadmap to reach 100,000 downloads. The
distribution strategy is **organic-first** because: (a) we have no budget
for ads, (b) ads would contradict the app's positioning, and (c) Islamic
content spreads best through community trust.

---

## Phase 1 — Launch (Month 1)

### Week 1: Soft launch
- [ ] **Submit to Google Play** (internal testing track first, then production)
- [ ] **Submit to Apple App Store** (TestFlight first if Apple Developer account available)
- [ ] **Submit to Huawei AppGallery**
- [ ] **Submit to F-Droid** (open MR; merge can take 4-8 weeks — start early)
- [ ] **Deploy Web PWA** to GitHub Pages: `https://mahmoodhamdi.github.io/nawawi_40_hadith_app/`
- [ ] **Polish GitHub README** with badges, screenshots, GIF demo, multilingual headline
- [ ] **Add GitHub topics**: islamic-app, hadith, nawawi, flutter, dawah, sadaqah-jariyah,
      open-source-islamic, offline-first, no-tracking

### Week 2: Personal network
- [ ] Share with 20 personal contacts (family, mosque, work) — measure their feedback
- [ ] Post in 3 personal WhatsApp groups
- [ ] LinkedIn post if professional network includes Muslims

### Week 3-4: Mosque outreach
- [ ] Print **A4 QR code posters** (see `marketing/outreach/poster_a4_*.md`)
- [ ] Reach out to local mosque imams personally (visit, don't email)
- [ ] Offer them the khateeb intro script (`marketing/outreach/khateeb_script_ar.md`)
- [ ] Print 50 cards with QR + "تطبيق مجاني بدون إعلانات" tagline
- [ ] Target: **20 mosques with posters by end of Month 1**

**Month 1 download target: 1,000**

---

## Phase 2 — Da'wah Influencer Outreach (Month 2-3)

### Outreach list (start with 30, expect 5-10 responses)
- Da'wah YouTubers (Islamic content)
- Twitter/X Islamic accounts (>10k followers, content-focused)
- Instagram Islamic accounts (visual content)
- Telegram Islamic channels (Arabic & Urdu have huge groups)
- WhatsApp group admins (Quran study groups, Islamic mothers groups)

### Pitch (use `marketing/outreach/influencer_kit.md`):
- 2-paragraph cold message in their language
- Sample social media content they can use (no attribution required)
- Direct download links + QR code
- "صدقة جارية لك ولكل من يقرأ بسببك" framing

### Target: **10 influencers post once → 10,000+ downloads** (Month 2-3)

---

## Phase 3 — Localization Expansion (Month 3-4)

Priority order (by Muslim population × app fit):
1. Indonesian (id) — 230M+ Muslims
2. Urdu (ur) — 200M+ Muslims
3. Turkish (tr) — 80M+ Muslims
4. French (fr) — 80M+ Muslims (West Africa + France + Maghreb diaspora)
5. Bengali (bn) — 160M+ Muslims
6. Malay (ms) — 30M+ Muslims (but Indonesian covers a lot of this)

For each language:
- UI strings translated (via `assets/l10n/intl_<code>.arb` — TBD via Flutter intl migration)
- Hadith translations sourced from authoritative sources only:
  - sunnah.com has nawawi40 in EN, ID, TR, UR — pull and verify
  - For others, find professional translations (do not auto-translate)

**Month 3-4 download target: 30,000 cumulative**

---

## Phase 4 — Ramadan / Eid Campaign (Schedule per Hijri calendar)

The single biggest distribution opportunity each year.

### 2 weeks before Ramadan
- [ ] Push v2.0 release with Ramadan-specific features:
  - Custom Ramadan reminder schedule (after Fajr, before Iftar)
  - "Daily hadith of Ramadan" rotation
  - Ramadan-themed share cards
- [ ] Reach out to all influencers again with a Ramadan-specific pitch
- [ ] Update store listing to mention Ramadan suitability

### During Ramadan
- [ ] Daily reminder time auto-adjusts (if prayer-time integration shipped)
- [ ] Social media reposts: daily hadith share card

### Eid Al-Fitr
- [ ] "Eid gift" announcement on social — share the app as Eidiyya
- [ ] Update card: "أهدِ الأربعون النووية لأحبابك"

### Hijri New Year
- [ ] Another organic push, themed on starting fresh

**Ramadan target: 50,000+ downloads in 30 days**

---

## Phase 5 — Apply for Featured Programs (Month 5-6)

Once download count is sufficient (10K+) and reviews are strong (4.5+):

- [ ] **Google Play "Editor's Choice"** — submit via Play Console "Promote" tab.
      Highlight: open-source, offline, no tracking, dawah-positioned.
- [ ] **Apple App Store "App of the Day"** — submit via App Store Connect
      featuring nomination form.
- [ ] **F-Droid "Featured"** — happens organically based on reviews.
- [ ] **Product Hunt** — schedule launch for a Friday (highest Muslim
      visibility); coordinate with Muslim PH community.

---

## Long-term sustenance (Month 6+)

- Maintain weekly hadith share on social
- Reply to every GitHub issue and review within 7 days
- Quarterly content update: refine sharh, fix typos, add references
- Annual major release before Ramadan
- Open a Patreon / Buy-Me-a-Coffee for those who want to contribute
  financially — but **never gate features behind it**. Keep it pure
  donation, used for:
  - Hosting (GitHub Pages, optional CDN for audio)
  - Future audio recordings by other reciters
  - Translation review fees

---

## Metrics to track

We don't collect data from users, but Play Console / App Store Connect
give us aggregate, non-personal metrics:

| Metric | Target by Month 6 |
|---|---|
| Total downloads | 100,000 |
| Daily active users | 8,000 |
| Average rating | 4.7+ |
| GitHub stars | 1,000 |
| GitHub contributors | 20 |
| Translations | 6 languages |
| Mosques distributing | 100 |

## What we WILL NOT do

- Run paid ads
- Add tracking even "anonymous"
- Add in-app purchases
- Add a paywall
- Compromise the Arabic text under any circumstance
- Accept sponsorship that requires placement
- Submit to stores that require closed-source builds
