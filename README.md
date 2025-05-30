# الأربعون النووية – بصوت الشيخ أحمد النفيس

![Version](https://img.shields.io/badge/الأربعون_النووية-1.0.2+4-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Status](https://img.shields.io/badge/Status-Active-success)

**صدقة جارية مفتوحة المصدر** – شارك في الأجر وطور معنا ❤️

![Built with Love](https://forthebadge.com/images/badges/built-with-love.svg)


## 📱 نبذة عن التطبيق

تطبيق **Flutter** إسلامي يعرض **الأربعين حديثًا النووية** مع إمكانية الاستماع إليها **بصوت الشيخ أحمد النفيس**، مع شرح مبسط وواجهة عصرية تدعم الوضع الليلي والفاتح.

## 🚀 المميزات الرئيسية

### 📚 عرض المحتوى

- **عرض نصوص الأربعين النووية** بشكل جميل وسهل القراءة
- **شرح مختصر وواضح** لكل حديث
- **تخصيص حجم الخط** للحديث والشرح بشكل منفصل
- **دعم كامل للغة العربية وواجهة RTL**

### 🔍 البحث والتصفح

- **بحث ذكي مع اقتراحات فورية** أثناء الكتابة
- **تظليل نتائج البحث** داخل النص لسهولة التتبع
- **تصفح سريع وسلاسة في التنقل بين الأحاديث**
- **أزرار التنقل (السابق/التالي)** للانتقال بين الأحاديث مباشرة من شاشة التفاصيل
- **حفظ آخر حديث تمت قراءته** والعودة إليه عند فتح التطبيق مرة أخرى

### 🎧 مشغل الصوت

- **تشغيل صوتي لكل حديث** (MP3) بصوت الشيخ أحمد النفيس
- **تحكم متقدم في الصوت** مع خيارات متعددة للسرعة والإيقاف المؤقت
- **التحكم في سرعة تشغيل الصوت** لتسهيل الاستماع والفهم

### 🎭 واجهة المستخدم

- **دعم الوضع الليلي والفاتح** مع إمكانية التبديل بينهما
- **واجهة مستخدم متجاوبة بالكامل** لجميع الشاشات
- **واجهة انسيابية مع Slivers** لتجربة تصفح سلسة وسريعة
- **تعدد الثيمات** مع خيارات متنوعة للألوان والمظهر
- **خط عربي احترافي (Cairo)** مدمج مع التطبيق

### 🛠️ ميزات أخرى

- **تجربة استخدام كاملة بدون إنترنت** (Offline First)
- **مشاركة الحديث أو الشرح أو كليهما** بسهولة
- **حفظ تفضيلات المستخدم** تلقائياً (حجم الخط، الثيم، إعدادات الصوت، مستوى التقدم)


## 📷 لقطات شاشة

*(سيتم إضافة صور في النسخ القادمة)*


## 🎨 التصميم والألوان

- **لوحة ألوان إسلامية** مستوحاة من التراث الإسلامي:
  - أخضر زيتوني
  - ذهبي
  - أبيض
  - رمادي مزرق
- **خط Cairo العربي** احترافي مدمج في التطبيق
- **واجهة متناسقة** مع تباين ممتاز للنصوص في جميع الأوضاع
- **ثيمات متعددة** تناسب تفضيلات المستخدمين المختلفة


## 🛠️ التقنيات المستخدمة

| التقنية | الاستخدام |
|---------|-----------|
| **Flutter 3+** | إطار عمل التطبيق |
| **BLoC (flutter_bloc)** | إدارة الحالة وتنظيم الكود |
| **just_audio** | تشغيل الملفات الصوتية |
| **responsive_framework** | تحسين عرض التطبيق على جميع الشاشات |
| **share_plus** | مشاركة محتوى الأحاديث |
| **shared_preferences** | حفظ إعدادات المستخدم وتفضيلاته |
| **Slivers** | واجهات انسيابية لتحسين الأداء |
| **Cairo Font** | خط عربي احترافي |
| **audio_service** | تحكم متقدم في تشغيل الصوت |


## ⚙️ التثبيت والتشغيل

### متطلبات التشغيل

- Flutter 3.0 أو أحدث
- Dart 2.17 أو أحدث

### خطوات التثبيت

1. استنساخ المشروع

   ```bash
   git clone https://github.com/mahmoodhamdi/nawawi_40_hadith_app.git
   ```

1. الدخول إلى مجلد المشروع

   ```bash
   cd nawawi_40_hadith_app
   ```

1. تثبيت الاعتماديات

   ```bash
   flutter pub get
   ```

1. تشغيل التطبيق

   ```bash
   flutter run
   ```

### بناء التطبيق للإصدار

```bash
flutter build apk --release
```

## 📁 هيكل المشروع

```text
nawawi_40_hadith_app/
├── assets/
│   ├── audio/                # ملفات MP3 لكل حديث
│   ├── json/                 # بيانات الأحاديث
│   ├── fonts/                # خط Cairo
│
├── lib/
│   ├── main.dart             # نقطة الدخول للتطبيق
│   ├── models/               # نماذج البيانات
│   │   ├──hadith.dart 
│   ├── screens/              # شاشات التطبيق
│   │   ├── home_screen.dart  # الشاشة الرئيسية (قائمة الأحاديث)
│   │   ├── hadith_details_screen.dart # شاشة تفاصيل الحديث
│   │
│   ├── cubit/                # إدارة الحالة باستخدام BLoC
│   │   ├── hadith_cubit.dart
│   │   ├── audio_player_cubit.dart
│   │   ├── font_size_cubit.dart
│   │   ├── theme_cubit.dart
│   │
│   ├── services/             # خدمات التطبيق
│   │   ├── hadith_loader.dart
│   │   ├── preferences_service.dart
│   │
│   ├── widgets/              # مكونات قابلة لإعادة الاستخدام
│   │   ├── audio_player_widget.dart
│   │   ├── hadith_tile.dart
│   │
│   ├── core/                 # مكونات أساسية
│       ├── theme/            # الألوان والثيمات
│       ├── strings.dart      # النصوص المركزية
```


## 🤝 المساهمة

> **كل مساهمة = أجر صدقة جارية بإذن الله**

### كيف تساهم؟

1. قم بعمل Fork للمشروع
2. أنشئ فرع جديد للميزة التي تريد إضافتها `git checkout -b feature/amazing-feature`
3. قم بإضافة تغييراتك واعتمادها `git commit -m 'Add amazing feature'`
4. ارفع التغييرات إلى الفرع الخاص بك `git push origin feature/amazing-feature`
5. افتح طلب سحب Pull Request

### أفكار للتطوير

- إضافة دعم للغات إضافية (الإنجليزية/الفرنسية)
- تحسين واجهة المشغل الصوتي
- إضافة خيارات بحث متقدمة وفلاتر
- دعم الإشعارات والتذكير اليومي بحديث
- إضافة اختبارات ذاتية للمستخدم
- تحسين تجربة المستخدم على الأجهزة اللوحية


## 📄 الترخيص

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للمزيد من التفاصيل.

الغرض الأساسي من المشروع هو نشر العلم ونيل أجر الصدقة الجارية بإذن الله.


## 👤 المطوّر

**[محمود حمدي](https://github.com/mahmoodhamdi)**

📬 للتواصل والمساهمة: افتح [Issue](https://github.com/mahmoodhamdi/nawawi_40_hadith_app/issues) أو تواصل مباشرة

🌟 إذا أعجبك المشروع، لا تنسى إضافة نجمة ⭐

---

اللهم اجعل هذا العمل خالصًا لوجهك الكريم، وارزقنا به الأجر والمغفرة
