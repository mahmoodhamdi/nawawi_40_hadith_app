# Release v1.5.0 — Android 16 Compliance

> اللهم اجعله صدقة جارية لمصممه ومطوّره ولكل من نشره.

## Artifact

| | |
|---|---|
| Bundle | `build/app/outputs/bundle/release/app-release.aab` (147.6 MB) |
| `versionName` | `1.5.0` |
| `versionCode` | `11` |
| `targetSdk` / `compileSdk` | `36` (Android 16) |
| `minSdk` | `24` |
| Signed with | `android/upload-keystore.jks` (`META-INF/UPLOAD.RSA`) |
| Permissions | `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, plus `ACCESS_NETWORK_STATE` (androidx.media3) and `DUMP` (androidx.profileinstaller) |

**No `INTERNET` permission.** The app still cannot make a network request; the
only outward hand-off is feedback, which leaves through WhatsApp or the share
sheet after the user presses send. The Play data-safety declaration does not
need to change.

## نصّ "الجديد في هذا الإصدار" | Store "What's new"

Play caps this at 500 characters per language.

### ar

```
• دعم أندرويد 16 (المستوى 36) بالكامل.
• واجهة أخفّ: الرئيسية والإعدادات أعيد ترتيبهما، والتقدّم و"متابعة القراءة" في بطاقة واحدة.
• بطاقة استمرارية جديدة بعدّاد الأيام وشريط آخر سبعة أيام.
• وسوم موضوعات لكل حديث وبطاقة "أحاديث ذات صلة".
• تذكير الجمعة ومواقيت تقريبية كإعدادات سريعة.
• إرسال ملاحظتك صار مباشرة على واتساب.
• أيقونة وشاشة بدء وحوارات جديدة.
التطبيق كما هو: بدون إنترنت ولا تتبّع ولا إعلانات.
```

### en-US

```
• Full Android 16 (API 36) support.
• Lighter UI: home and settings rebuilt to use the screen; progress and "continue reading" now share one card.
• New streak card with a seven-day strip.
• Topic tags per hadith and a "related hadiths" card.
• Friday reminder plus approximate prayer-time presets.
• Feedback now goes straight to WhatsApp.
• Refreshed icon, splash screen and dialogs.
Still fully offline: no tracking, no ads.
```

## Publishing checklist

1. **Check the highest uploaded `versionCode`** in *الاختبار والإصدار → أحدث
   الإصدارات والحزم*. This bundle is `11`; Play rejects anything not strictly
   greater than what is already uploaded. If `11` is taken, bump `version:` in
   `pubspec.yaml` **and** `AppInfo.appVersion` in `lib/core/constants.dart`, then
   rebuild.
2. **Look at *نظرة عامة على النشر* before uploading.** Anything already sitting
   in *التغييرات قيد المراجعة* ships together with this release — confirm the
   country changes there are intended.
3. *مرحلة الإنتاج → إنشاء إصدار جديد* → upload the `.aab` → paste the notes above.
4. *حفظ → مراجعة الإصدار → بدء الطرح إلى مرحلة الإنتاج*.
5. Review takes up to 7 days. The API-36 policy warning clears on its own once
   the build is live — no separate action, and no need to request an extension.
