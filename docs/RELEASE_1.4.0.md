# Release v1.4.0 — Dawah Expansion

> اللهم اجعله صدقة جارية لمصممه ومطوّره ولكل من نشره.

## نظرة عامة | Overview

إصدار 1.4.0 يحول التطبيق من قارئ أحاديث إلى منصة دعوية متكاملة:
المراجع الشرعية الموثقة، أدوات الحفظ والمراجعة، صدقة جارية بنسخ احتياطية محلية، وإكسبورت PDF — كلها مع الحفاظ على وعد التطبيق الأساسي:
**بدون إنترنت، بدون إعلانات، بدون تتبع**.

Version 1.4.0 transforms the app from a hadith reader into a complete
da'wah platform: verified citations, memorization and review tools, local
backup as ongoing charity, and PDF export — all while preserving the
core promise: **fully offline, no ads, no tracking**.

---

## أبرز الإضافات | Highlights

### 📖 محتوى موثق | Verified content
- **كل الـ 42 حديث** الآن مع مرجع موثّق:
  - الراوي من الصحابة رضي الله عنهم
  - المصدر (البخاري، مسلم، الترمذي، إلخ)
  - رابط مباشر لـ sunnah.com للمراجعة
- نص الحديث العربي **لم يُمَس بأي تعديل** — صيانة لكلام النبي ﷺ.
- Display-only typo log في `.agent/content_issues.md` للمراجعة البشرية.

### 🔥 استمرارية القراءة | Reading Streaks
- متتابعة أيام القراءة الحالية + أطول متتابعة (محلية بالكامل)
- **بدون gamification** — صياغة لطيفة باسم "الاستمرارية"، لا "نقاط" ولا "مستويات"
- مؤشر على الشاشة الرئيسية + قسم في الإعدادات

### 📝 ملاحظاتك على الأحاديث | Personal Notes
- ملاحظة شخصية لكل حديث (Markdown، محلية فقط)
- محرر داخل صفحة تفاصيل الحديث بين المرجع والشرح
- مدرجة تلقائياً في النسخ الاحتياطية

### 🎓 وضع الحفظ | Memorize Mode
- إخفاء نص الحديث + كشف باللمس
- يتم إعادة الإخفاء عند التنقل لحديث جديد
- زر في AppBar صفحة التفاصيل

### 🎲 اختبر معرفتك | Quiz Mode
- جلسة 10 أسئلة:
  - من الراوي؟
  - من المصدر (المخرج)؟
  - أي حديث ينتمي إليه هذا النص؟
- بدون مؤقت ولا ضغط — هدفنا التعلم
- صفحة نتائج تستعرض الإجابات الصحيحة

### 💾 نسخ احتياطي محلي | Local Backup
- تصدير كل الإعدادات والمفضلة والملاحظات كملف JSON عبر share sheet
- استيراد عبر paste JSON في dialog
- بدون cloud، بدون رفع، بدون حساب
- Schema versioning + allowlist للأمان

### 📩 إرسال ملاحظات | In-App Feedback
- زر في الإعدادات يفتح share sheet مع نص جاهز
- يتضمن معلومات الجهاز (غير معرّفة)
- بدون backend، بدون API key

### 🖨️ تصدير PDF | PDF Export
- حديث واحد أو الـ 42 حديث ككتاب PDF
- خط Cairo مدمج في الـ PDF
- صفحة غلاف، فهرس، شرح، مرجع

### 🎨 ثيم سيبيا | Sepia Theme
- ثيم خامس بدرجات الرق والورق الإسلامي
- مريح للعين في الإضاءة المنخفضة
- WCAG AA compliant

### 🎨 ٣ أنماط لمشاركة الصور | 3 Share Card Templates
- **كلاسيكي**: التصميم الأصلي بالخلفية الملوّنة
- **بسيط**: محرّر، خلفية كريمي، أنيق للطباعة
- **مزخرف**: مستوحى من المخطوطات الإسلامية

### 🌐 تحضيرات الترجمة | Localization scaffolding
- 94 string منسوخة من الـ AppLocalizations الحالية إلى ARB ملفات
- خطة هجرة كاملة في `docs/L10N_MIGRATION.md`
- جاهز لإضافة الإندونيسية، الأردية، التركية في الإصدار القادم

---

## للتطوير الذاتي | Developer additions

- **5 GitHub Actions workflows**: analyze, test, build_android, build_web, release
- **300+ test cases** — Cubits, services, models، deterministic Random seeding
- **94 social graphic** جاهزة للنشر:
  - 42 hadith square cards (1080×1080)
  - 42 hadith story cards (1080×1920)
  - 10 app promo cards (5 designs × 2 sizes)
- مكتبة Marketing كاملة (store listings × 4 لغات، DAWAH_PLAN، khateeb scripts، إلخ)

---

## الحفاظ على الوعود | Promises kept

- ✅ صفر بيانات شخصية مجمّعة
- ✅ صفر SDK لتحليلات أو إعلانات
- ✅ صفر صلاحيات جديدة على Android أو iOS
- ✅ صفر اتصال إنترنت من التطبيق
- ✅ صفر تعديل على نص الحديث العربي
- ✅ الكود مفتوح بالكامل بترخيص MIT

---

## التحديث | Updating

- **من 1.3.x**: التحديث آمن. الإعدادات والمفضلة والإحصائيات تنتقل تلقائياً.
- **حجم APK**: زاد ~1MB بسبب dependency `pdf` + `printing`.
- **dependencies جديدة**: `pdf ^3.11.1`, `printing ^5.13.3` — كلاهما pure-Dart.

---

## الشكر | Thanks

- لكل من اقترح ميزة أو أبلغ عن خطأ
- لمن ترجم وراجع المحتوى
- للشيخ أحمد النفيس على التلاوة
- لـ sunnah.com على فهرسة الأحاديث المتاحة علناً

اللهم انفع به وبارك فيه.
