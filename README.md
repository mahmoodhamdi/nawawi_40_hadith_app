# الأربعون النووية – بصوت الشيخ أحمد النفيس

<div align="center">

![Version](https://img.shields.io/badge/الإصدار-1.0.2-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.8+-blue)
![Dart](https://img.shields.io/badge/Dart-3.8+-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-orange)
![Status](https://img.shields.io/badge/Status-Active-success)

**صدقة جارية مفتوحة المصدر** – شارك في الأجر وطور معنا

[تحميل التطبيق](#-التثبيت) • [المساهمة](#-المساهمة) • [خطة التطوير](docs/IMPROVEMENT_PLAN.md)

</div>

---

## نبذة عن التطبيق

تطبيق **Flutter** إسلامي يعرض **الأحاديث النووية** مع إمكانية الاستماع إليها **بصوت الشيخ أحمد النفيس**، مع شرح مبسط وواجهة عصرية تدعم الوضع الليلي والفاتح.

### لماذا هذا التطبيق؟

- **بدون إنترنت**: كل المحتوى متاح offline
- **بدون إعلانات**: تجربة نقية بدون تشتيت
- **مفتوح المصدر**: شارك في الأجر بالتطوير
- **خفيف وسريع**: حجم صغير وأداء ممتاز

---

## المميزات

### المحتوى
| الميزة | الوصف |
|--------|--------|
| النصوص | عرض الأحاديث بخط واضح وجميل |
| الشرح | شرح مبسط لكل حديث |
| الصوت | تلاوة بصوت الشيخ أحمد النفيس |
| البحث | بحث فوري في الأحاديث والشروح |

### التحكم بالصوت
| الميزة | الوصف |
|--------|--------|
| تشغيل/إيقاف | التحكم الكامل في التشغيل |
| تقديم/رجوع | القفز 10 ثواني للأمام أو الخلف |
| سرعة التشغيل | تغيير سرعة الصوت (0.5x - 2x) |
| شريط التقدم | التنقل في أي نقطة من الصوت |

### واجهة المستخدم
| الميزة | الوصف |
|--------|--------|
| الثيمات | فاتح، داكن، أزرق، بنفسجي، نظام |
| حجم الخط | تكبير وتصغير منفصل للحديث والشرح |
| RTL | دعم كامل للغة العربية |
| متجاوب | يعمل على جميع أحجام الشاشات |

### مميزات إضافية
| الميزة | الوصف |
|--------|--------|
| متابعة القراءة | حفظ آخر حديث تمت قراءته |
| التنقل | أزرار للحديث السابق والتالي |
| المشاركة | مشاركة الحديث أو الشرح أو كليهما |
| نسبة الإنجاز | عرض التقدم في قراءة الأحاديث |

---

## التقنيات المستخدمة

```
Flutter 3.8+          إطار العمل
Dart 3.8+             لغة البرمجة
flutter_bloc          إدارة الحالة (Cubit)
just_audio            مشغل الصوت
shared_preferences    حفظ الإعدادات
responsive_framework  التصميم المتجاوب
share_plus            مشاركة المحتوى
```

---

## هيكل المشروع

```
lib/
├── main.dart                 # نقطة الدخول
├── core/
│   ├── strings.dart          # النصوص المركزية
│   └── theme/                # نظام الثيمات
│       ├── app_theme.dart
│       ├── light_theme.dart
│       ├── dark_theme.dart
│       ├── blue_theme.dart
│       └── purple_theme.dart
├── cubit/                    # إدارة الحالة
│   ├── audio_player_cubit.dart
│   ├── font_size_cubit.dart
│   ├── hadith_cubit.dart
│   ├── last_read_cubit.dart
│   └── theme_cubit.dart
├── models/
│   └── hadith.dart           # نموذج البيانات
├── screens/
│   ├── home_screen.dart      # الشاشة الرئيسية
│   └── hadith_details_screen.dart
├── services/
│   ├── hadith_loader.dart    # تحميل البيانات
│   └── preferences_service.dart
└── widgets/
    ├── audio_player_widget.dart
    └── hadith_tile.dart

assets/
├── audio/                    # ملفات MP3 (42 ملف)
├── fonts/                    # خط Cairo
└── json/                     # بيانات الأحاديث
```

---

## التثبيت

### متطلبات التشغيل
- Flutter 3.8 أو أحدث
- Dart 3.8 أو أحدث

### خطوات التثبيت

```bash
# 1. استنساخ المشروع
git clone https://github.com/mahmoodhamdi/nawawi_40_hadith_app.git

# 2. الدخول للمجلد
cd nawawi_40_hadith_app

# 3. تثبيت الاعتماديات
flutter pub get

# 4. تشغيل التطبيق
flutter run
```

### بناء التطبيق

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## التطوير

### الأوامر المفيدة

```bash
# تشغيل الاختبارات
flutter test

# تحليل الكود
flutter analyze

# تنسيق الكود
dart format lib/

# تحديث الاعتماديات
flutter pub upgrade
```

### البنية المعمارية

التطبيق يستخدم **BLoC/Cubit Pattern** لإدارة الحالة:

```
View (Screens/Widgets)
         ↓ events
      Cubit
         ↓ states
View (Screens/Widgets)
```

| Cubit | المسؤولية |
|-------|-----------|
| HadithCubit | تحميل وإدارة الأحاديث |
| AudioPlayerCubit | التحكم في الصوت |
| ThemeCubit | إدارة الثيمات |
| FontSizeCubit | حجم الخط |
| LastReadCubit | آخر قراءة |

---

## المساهمة

> **كل مساهمة = أجر صدقة جارية بإذن الله**

### كيف تساهم؟

1. **Fork** المشروع
2. أنشئ **Branch** جديد
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. اكتب **الاختبارات** أولاً
4. نفذ التغييرات
5. تأكد من مرور الاختبارات
   ```bash
   flutter test
   flutter analyze
   ```
6. **Commit** التغييرات
   ```bash
   git commit -m "feat: add amazing feature"
   ```
7. **Push** للـ Branch
   ```bash
   git push origin feature/amazing-feature
   ```
8. افتح **Pull Request**

### أفكار للمساهمة

راجع [خطة التطوير](docs/IMPROVEMENT_PLAN.md) للقائمة الكاملة:

#### مطلوب بشدة
- [ ] إضافة اختبارات الوحدة (Unit Tests)
- [ ] نظام المفضلة/الإشارات المرجعية
- [ ] تحسين البحث (debounce + case-insensitive)
- [ ] إضافة Accessibility labels

#### مميزات جديدة
- [ ] تذكير يومي بحديث
- [ ] إحصائيات القراءة
- [ ] دعم لغات إضافية (الإنجليزية/الفرنسية)
- [ ] مشاركة كصورة
- [ ] وضع القراءة المركز

#### تحسينات
- [ ] تحسين أداء البحث
- [ ] إضافة تحريكات (Animations)
- [ ] دعم الأجهزة اللوحية بشكل أفضل

---

## خارطة الطريق

### الإصدار 1.1 (قريباً)
- [ ] نظام المفضلة
- [ ] تحسين البحث
- [ ] اختبارات شاملة

### الإصدار 1.2
- [ ] التذكيرات اليومية
- [ ] إحصائيات القراءة
- [ ] مشاركة كصورة

### الإصدار 2.0
- [ ] دعم اللغة الإنجليزية
- [ ] المزامنة السحابية
- [ ] تطبيق Apple Watch

---

## الترخيص

هذا المشروع مرخص تحت رخصة **MIT** - راجع ملف [LICENSE](LICENSE) للتفاصيل.

الغرض الأساسي من المشروع هو **نشر العلم** ونيل **أجر الصدقة الجارية** بإذن الله.

---

## المطوّر

**[محمود حمدي](https://github.com/mahmoodhamdi)**

للتواصل والمساهمة:
- افتح [Issue](https://github.com/mahmoodhamdi/nawawi_40_hadith_app/issues)
- أو تواصل عبر GitHub

---

<div align="center">

**إذا أعجبك المشروع، لا تنسى إضافة نجمة** ⭐

اللهم اجعل هذا العمل خالصًا لوجهك الكريم، وارزقنا به الأجر والمغفرة

</div>
