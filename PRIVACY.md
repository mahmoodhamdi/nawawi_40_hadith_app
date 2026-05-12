# سياسة الخصوصية | Privacy Policy

**آخر تحديث | Last updated:** 2026-05-12

---

## English

### TL;DR

**The app collects nothing.** It works fully offline. There is no
analytics, no tracking, no account, no cloud sync, no third-party SDK
that phones home. The only data the app stores is your local preferences
on your own device.

### Data we collect

**None.** No personal data, no usage data, no device identifiers, no IP
address, no crash logs, no analytics events are collected, transmitted,
or shared. There is no server backend.

### Data the app stores on your device (locally)

The app uses the operating system's local preferences store
(`SharedPreferences` on Android / `NSUserDefaults` on iOS) to remember
your in-app choices. **This data never leaves your device.**

- Selected theme (Light / Dark / Blue / Purple)
- Selected language (Arabic / English)
- Font-size preferences for hadith body and explanation
- Favorite hadiths (a list of numbers)
- Last hadith you read (one number)
- Reading progress (which hadiths you've marked as read)
- Search history (recent search queries)
- Daily-reminder time and enabled/disabled state
- Any per-hadith notes you have written

When you uninstall the app, this data is deleted by the operating
system.

### Permissions the app uses

| Permission | Why |
|---|---|
| `POST_NOTIFICATIONS` (Android 13+) | To show the daily hadith reminder you configure |
| `SCHEDULE_EXACT_ALARM` (Android) | To schedule the daily reminder at the time you choose |
| `RECEIVE_BOOT_COMPLETED` (Android) | To re-schedule your daily reminder after device restart |
| `VIBRATE` (Android) | Optional tactile feedback when the reminder fires |

The app does **NOT** request:
- Internet access
- Location
- Camera or microphone
- Contacts, calendar, or photos
- Storage beyond its own app sandbox
- Phone state or device identifiers

### Third-party services

The app uses **no third-party analytics, advertising, or crash-reporting
service**. There is no Firebase, no Google Analytics, no Facebook SDK,
no AppsFlyer, no Adjust, no Sentry, no Bugsnag.

The only external library categories used are:
- UI rendering (Flutter framework)
- Audio playback (`just_audio` — local files only)
- Local notifications (`flutter_local_notifications` — local only)
- System share dialog (`share_plus` — invokes OS share sheet)
- Timezone handling (`timezone`, `flutter_timezone` — local computation)

### Audio files

Audio recitation by Sheikh Ahmad Al-Nafees is **bundled in the app**.
Audio is played from the local app bundle. **No streaming, no audio
analytics, no usage of any media network service.**

### Sharing

When you tap "Share" or "Share as image", the app hands the content to
your operating system's share dialog. From that point, the OS and the
app you choose (WhatsApp, Twitter, etc.) handle the content. Their
privacy policies apply to what happens next. The Forty Hadith app
itself never sees where the share went.

### Optional Sunnah.com link

The hadith details screen includes a "Reference on sunnah.com" row.
**Tapping it copies the URL to your clipboard — it does not open any
URL automatically and the app does not request internet access to
visit sunnah.com.** You may paste the URL into your browser if you
wish to visit the source.

### Children's privacy

The app is suitable for all ages. We do not knowingly collect any data
from anyone, including children. The app has no advertising and no
user accounts.

### Open source

The source code is publicly available at
https://github.com/mahmoodhamdi/nawawi_40_hadith_app

You — or anyone — can independently verify these claims by inspecting
the code.

### Changes to this policy

If this policy ever changes, the new version will be committed to the
public repository with a clear changelog entry.

### Contact

For privacy questions, open an issue at:
https://github.com/mahmoodhamdi/nawawi_40_hadith_app/issues

---

## العربية

### الخلاصة

**التطبيق لا يجمع أي شيء.** يعمل بدون إنترنت تماماً. لا يوجد تحليلات، لا
تتبع، لا حسابات، لا مزامنة سحابية، ولا أي SDK خارجي يتصل بأي خادم.
البيانات الوحيدة التي يحفظها التطبيق هي تفضيلاتك المحلية على جهازك أنت.

### البيانات التي نجمعها

**لا شيء.** لا بيانات شخصية، لا بيانات استخدام، لا معرّفات جهاز، لا
عنوان IP، لا سجلات أعطال، لا أحداث تحليلية تُجمع أو تُنقل أو تُشارك.
لا يوجد خادم backend أصلاً.

### البيانات التي يخزنها التطبيق على جهازك (محلياً)

يستخدم التطبيق متجر التفضيلات المحلي للنظام (`SharedPreferences` على
أندرويد / `NSUserDefaults` على iOS) لتذكر اختياراتك داخل التطبيق.
**هذه البيانات لا تغادر جهازك أبداً.**

- الثيم المختار (فاتح / داكن / أزرق / بنفسجي)
- اللغة المختارة (العربية / الإنجليزية)
- إعدادات حجم الخط للحديث والشرح
- الأحاديث المفضلة (قائمة أرقام)
- آخر حديث قرأته (رقم واحد)
- تقدم القراءة (الأحاديث المحددة كمقروءة)
- سجل البحث (آخر عمليات البحث)
- وقت التذكير اليومي وحالة التفعيل
- أي ملاحظات شخصية كتبتها على الأحاديث

عند إلغاء تثبيت التطبيق، يحذف نظام التشغيل هذه البيانات.

### الصلاحيات

| الصلاحية | السبب |
|---|---|
| `POST_NOTIFICATIONS` (أندرويد 13+) | لعرض تذكير الحديث اليومي اللي تختاره |
| `SCHEDULE_EXACT_ALARM` (أندرويد) | لجدولة التذكير في الوقت المختار |
| `RECEIVE_BOOT_COMPLETED` (أندرويد) | لإعادة جدولة التذكير بعد إعادة تشغيل الجهاز |
| `VIBRATE` (أندرويد) | اهتزاز اختياري عند التذكير |

التطبيق **لا** يطلب:
- الإنترنت
- الموقع
- الكاميرا أو الميكروفون
- جهات الاتصال أو التقويم أو الصور
- التخزين خارج صندوق التطبيق
- معرّف الجهاز

### خدمات الطرف الثالث

**لا يستخدم التطبيق أي خدمة تحليلات أو إعلانات أو تقارير أعطال من
طرف ثالث.** لا Firebase، لا Google Analytics، لا Facebook SDK، لا
AppsFlyer، لا Adjust، لا Sentry، لا Bugsnag.

### الملفات الصوتية

تلاوة الشيخ أحمد النفيس **مضمّنة في التطبيق نفسه**. يتم تشغيل الصوت من
الحزمة المحلية. **لا توجد بث، لا تحليلات صوتية، لا أي استخدام لأي
خدمة شبكة media.**

### المشاركة

عند الضغط على "مشاركة" أو "مشاركة كصورة"، يسلّم التطبيق المحتوى
لنافذة مشاركة نظام التشغيل. من تلك اللحظة، النظام والتطبيق اللي
تختاره (واتساب، تويتر، إلخ) يتولّوا الأمر. سياسات الخصوصية الخاصة بهم
تطبق. التطبيق نفسه لا يرى أين ذهبت المشاركة.

### رابط Sunnah.com الاختياري

شاشة تفاصيل الحديث تحتوي على صف "الرجوع إلى sunnah.com". **الضغط
عليه ينسخ الرابط للحافظة فقط — لا يفتح أي رابط تلقائياً ولا يطلب
التطبيق الإنترنت لزيارة sunnah.com.** بإمكانك لصق الرابط في
المتصفح لاحقاً إذا أردت زيارة المصدر.

### خصوصية الأطفال

التطبيق مناسب لكل الأعمار. نحن لا نجمع أي بيانات من أي شخص، بمن فيهم
الأطفال. التطبيق لا يحتوي على إعلانات ولا حسابات.

### المصدر المفتوح

الكود المصدري متاح علناً على:
https://github.com/mahmoodhamdi/nawawi_40_hadith_app

تستطيع أنت — أو أي شخص — التحقق من هذه الادعاءات بفحص الكود.

### التغييرات على هذه السياسة

لو تغيرت السياسة، النسخة الجديدة هتُحفظ في الـ repo العام مع changelog
واضح.

### التواصل

لأي أسئلة حول الخصوصية، افتح issue على:
https://github.com/mahmoodhamdi/nawawi_40_hadith_app/issues

---

**والله أعلم.** هذه السياسة عهد صدق مع مستخدمينا. اللهم اجعل هذا
التطبيق صدقة جارية لكل من شارك فيه، وثبتنا على هذا العهد.
