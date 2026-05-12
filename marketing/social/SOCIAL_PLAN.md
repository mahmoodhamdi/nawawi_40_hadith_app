# Social Media Asset Plan

This directory will hold generated images. Since this session can't run a
graphic-design tool, here's the **production plan** with exact dimensions
and design specs for whoever generates the final assets (Canva, Figma,
Photoshop, ImageMagick scripts, etc.).

## Asset matrix

| Type | Dimension | Purpose | Count |
|---|---|---|---|
| App promo square | 1080×1080 | Instagram feed, Facebook | 5 |
| Story | 1080×1920 | Instagram/WhatsApp story | 5 |
| Twitter card | 1600×900 | Twitter/X cards, LinkedIn | 3 |
| Facebook event | 1200×630 | Facebook page banner | 3 |
| YouTube thumb | 1280×720 | YouTube Shorts thumbnails | 3 |
| Hadith quote card | 1080×1080 | Per-hadith shareable | 42 |
| Hadith story | 1080×1920 | Per-hadith story version | 42 |

Total: **~120 assets** for full coverage. MVP: **10 promo + 10 hadith quote cards** = 20.

## Design language

- **Primary color**: #1F6E3A (الأخضر الإسلامي الكلاسيكي)
- **Accent**: #C9A961 (الذهبي المطفي للزخرفة)
- **Background**: #FAFAF5 (الأبيض الكريمي يريح العين)
- **Text dark**: #1A1A1A
- **Text muted**: #5C5C5C

### Typography
- **Arabic**: Cairo (already bundled) — Bold for headings, Regular for body
- **English**: Inter or system font
- **Calligraphy moments** (for the hadith text itself, not UI): Amiri or
  Scheherazade — pull from Google Fonts

### Iconography
- Avoid pictorial representations of the Prophet ﷺ or Sahabah
- Avoid faces in general (cultural sensitivity in many Muslim cultures)
- Use: book icons, calligraphic ornaments, geometric patterns
- Star-and-crescent: avoid (politicized symbol); use book/lamp instead

### Layout principles
- Generous whitespace (Islamic art tradition values negative space)
- Symmetry on horizontal axis (RTL/LTR neutrality)
- Hadith text always with proper diacritics in graphics (هي رواية، فالضبط مهم)

## Hadith quote card spec (the 42-asset series)

```
┌────────────────────────────┐ 1080×1080
│  [ornament top, gold]      │
│                            │
│       الحديث الأول         │  ← Cairo Bold 48px, gold
│                            │
│  ━━━━━━━━━━━━━━━━━━━━━     │
│                            │
│  "إنما الأعمال بالنيات"    │  ← Amiri 64px, dark green
│   وإنما لكل امرئ ما نوى     │
│                            │
│       رواه البخاري ومسلم    │  ← Cairo Regular 28px, muted
│                            │
│  [ornament bottom, gold]   │
│                            │
│   [logo / QR small bottom] │  ← brand mark, very subtle
└────────────────────────────┘
```

## Implementation suggestion

Use a Python script with Pillow to generate all 42 cards from the JSON:
this guarantees consistency. Example pseudo-code:

```python
from PIL import Image, ImageDraw, ImageFont
import json

hadiths = json.load(open('assets/json/40-hadith-nawawi.json'))

for i, h in enumerate(hadiths, 1):
    img = Image.new('RGB', (1080, 1080), '#FAFAF5')
    draw = ImageDraw.Draw(img)
    # ... layout logic
    img.save(f'marketing/social/cards/hadith_{i:02d}.png')
```

A working version of this script can be added in a follow-up — the
fonts (Cairo Bold/Regular) are already in `assets/fonts/`.

## Brand do's and don'ts

✓ DO show the hadith text prominently
✓ DO include the citation ("رواه ...")
✓ DO use traditional Islamic ornamentation tastefully
✗ DON'T include any logos other than the app's own
✗ DON'T use Western-style "click to download" CTA — feels off-brand
✗ DON'T animate the Arabic text into a wave/effect — disrespect the رواية
✗ DON'T use emojis on the hadith cards (OK on promo cards only)
