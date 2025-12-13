# الأربعون النووية – بصوت الشيخ أحمد النفيس
# Forty Hadith Nawawi – Narrated by Sheikh Ahmad Al-Nafees

<div align="center">

![Version](https://img.shields.io/badge/الإصدار-1.2.1-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.8+-blue)
![Dart](https://img.shields.io/badge/Dart-3.8+-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-orange)
![Status](https://img.shields.io/badge/Status-Active-success)
![Tests](https://img.shields.io/badge/Tests-269%20passing-brightgreen)
![Languages](https://img.shields.io/badge/Languages-Arabic%20|%20English-purple)

**صدقة جارية مفتوحة المصدر** – شارك في الأجر وطور معنا

**Open source ongoing charity** – Join in the reward and develop with us

[تحميل التطبيق](#-التثبيت) • [المساهمة](#-المساهمة) • [خطة التطوير](docs/IMPROVEMENT_PLAN.md)

</div>

---

## نبذة عن التطبيق | About the App

تطبيق **Flutter** إسلامي يعرض **الأحاديث النووية** مع إمكانية الاستماع إليها **بصوت الشيخ أحمد النفيس**، مع شرح مبسط وواجهة عصرية تدعم **العربية والإنجليزية**.

An **Islamic Flutter app** that displays the **Forty Hadith Nawawi** with audio narration by **Sheikh Ahmad Al-Nafees**, featuring explanations and a modern interface supporting **Arabic and English**.

### لماذا هذا التطبيق؟ | Why This App?

- **بدون إنترنت**: كل المحتوى متاح offline | **Offline**: All content available offline
- **بدون إعلانات**: تجربة نقية بدون تشتيت | **Ad-free**: Pure experience without distractions
- **مفتوح المصدر**: شارك في الأجر بالتطوير | **Open source**: Earn reward by contributing
- **خفيف وسريع**: حجم صغير وأداء ممتاز | **Light & fast**: Small size, excellent performance
- **ثنائي اللغة**: دعم كامل للعربية والإنجليزية | **Bilingual**: Full Arabic and English support

---

## المميزات | Features

### المحتوى | Content
| الميزة | الوصف | Feature | Description |
|--------|--------|---------|-------------|
| النصوص | عرض الأحاديث بخط واضح | Texts | Clear hadith display |
| الشرح | شرح مبسط لكل حديث | Explanation | Simple explanation for each hadith |
| الصوت | تلاوة بصوت الشيخ أحمد النفيس | Audio | Narration by Sheikh Ahmad Al-Nafees |
| البحث | بحث فوري في الأحاديث + بحث برقم الحديث | Search | Instant search + search by hadith number |
| سجل البحث | حفظ عمليات البحث الأخيرة | Search History | Save recent searches |
| اللغات | عربي وإنجليزي | Languages | Arabic and English |

### التحكم بالصوت | Audio Controls
| الميزة | الوصف | Feature | Description |
|--------|--------|---------|-------------|
| تشغيل/إيقاف | التحكم الكامل | Play/Pause | Full control |
| تقديم/رجوع | القفز 10 ثواني | Skip | Jump 10 seconds |
| سرعة التشغيل | 0.5x - 2x | Speed | 0.5x - 2x playback |
| شريط التقدم | التنقل في الصوت | Progress | Navigate audio |

### واجهة المستخدم | User Interface
| الميزة | الوصف | Feature | Description |
|--------|--------|---------|-------------|
| الثيمات | فاتح، داكن، أزرق، بنفسجي | Themes | Light, Dark, Blue, Purple |
| حجم الخط | تكبير وتصغير | Font Size | Increase and decrease |
| RTL/LTR | دعم العربية والإنجليزية | RTL/LTR | Arabic and English support |
| متجاوب | جميع أحجام الشاشات | Responsive | All screen sizes |

### مميزات إضافية | Additional Features
| الميزة | الوصف | Feature | Description |
|--------|--------|---------|-------------|
| المفضلة | حفظ الأحاديث المفضلة | Favorites | Save favorite hadiths |
| الإحصائيات | تقدم القراءة | Statistics | Reading progress |
| متابعة القراءة | آخر حديث | Continue | Last read hadith |
| المشاركة | نص أو صورة | Share | Text or image |
| القراءة المركزة | وضع غامر | Focused Reading | Immersive mode |
| التذكيرات | تذكير يومي | Reminders | Daily reminder |
| تبديل اللغة | عربي/إنجليزي | Language Switch | Arabic/English |

---

## التقنيات المستخدمة | Technologies

```
Flutter 3.8+                   Framework
Dart 3.8+                      Language
flutter_bloc                   State Management (Cubit)
just_audio                     Audio Player
shared_preferences             Settings Storage
responsive_framework           Responsive Design
share_plus                     Content Sharing
flutter_local_notifications    Local Notifications
timezone                       Timezone Management
flutter_localizations          Localization
```

---

## هيكل المشروع | Project Structure

```
lib/
├── main.dart                 # Entry point
├── core/
│   ├── constants.dart        # Centralized constants
│   ├── l10n/                 # Localization
│   │   └── app_localizations.dart
│   └── theme/                # Theme system
│       ├── app_theme.dart
│       ├── light_theme.dart
│       ├── dark_theme.dart
│       ├── blue_theme.dart
│       └── purple_theme.dart
├── cubit/                    # State management
│   ├── audio_player_cubit.dart
│   ├── favorites_cubit.dart
│   ├── font_size_cubit.dart
│   ├── hadith_cubit.dart
│   ├── language_cubit.dart   # Language management
│   ├── last_read_cubit.dart
│   ├── reading_stats_cubit.dart
│   ├── reminder_cubit.dart
│   ├── search_history_cubit.dart  # Search history
│   └── theme_cubit.dart
├── models/
│   └── hadith.dart           # Bilingual hadith model
├── screens/
│   ├── home_screen.dart
│   ├── hadith_details_screen.dart
│   ├── focused_reading_screen.dart
│   └── settings_screen.dart  # Language & reminder settings
├── services/
│   ├── hadith_loader.dart    # Loads Arabic & English
│   ├── notification_service.dart
│   ├── preferences_service.dart
│   └── share_image_service.dart
└── widgets/
    ├── audio_player_widget.dart
    └── hadith_tile.dart

assets/
├── audio/                    # MP3 files (42 files)
├── fonts/                    # Cairo font
└── json/
    ├── 40-hadith-nawawi.json     # Arabic hadiths
    └── 40-hadith-nawawi-en.json  # English hadiths
```

---

## التثبيت | Installation

### متطلبات التشغيل | Requirements
- Flutter 3.8 or later
- Dart 3.8 or later

### خطوات التثبيت | Installation Steps

```bash
# 1. Clone the project
git clone https://github.com/mahmoodhamdi/nawawi_40_hadith_app.git

# 2. Enter the directory
cd nawawi_40_hadith_app

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

### بناء التطبيق | Building the App

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

## التطوير | Development

### الأوامر المفيدة | Useful Commands

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Update dependencies
flutter pub upgrade
```

### الاختبارات | Tests

التطبيق يحتوي على **269 اختبار** شامل | The app contains **269 comprehensive tests**:

| النوع / Type | العدد / Count | الوصف / Description |
|-------|-------|-------|
| Unit Tests | 256 | Component unit tests |
| Integration Tests | 13 | Interface integration tests |

```
test/
├── cubit/
│   ├── audio_player_cubit_test.dart    (25 tests)
│   ├── favorites_cubit_test.dart       (27 tests)
│   ├── font_size_cubit_test.dart       (20 tests)
│   ├── hadith_cubit_test.dart          (12 tests)
│   ├── last_read_cubit_test.dart       (14 tests)
│   ├── reading_stats_cubit_test.dart   (33 tests)
│   ├── reminder_cubit_test.dart        (23 tests)
│   ├── search_history_cubit_test.dart  (28 tests)
│   └── theme_cubit_test.dart           (15 tests)
├── models/
│   └── hadith_test.dart                (16 tests)
├── services/
│   ├── preferences_service_test.dart   (34 tests)
│   └── share_image_service_test.dart   (19 tests)
└── widget_test.dart                    (10 tests)

integration_test/
└── app_test.dart                       (13 tests)
```

### البنية المعمارية | Architecture

التطبيق يستخدم **BLoC/Cubit Pattern** لإدارة الحالة:
The app uses **BLoC/Cubit Pattern** for state management:

```
View (Screens/Widgets)
         ↓ events
      Cubit
         ↓ states
View (Screens/Widgets)
```

| Cubit | المسؤولية / Responsibility |
|-------|-----------|
| HadithCubit | Load and manage hadiths |
| AudioPlayerCubit | Audio control |
| ThemeCubit | Theme management |
| FontSizeCubit | Font size |
| LastReadCubit | Last read tracking |
| FavoritesCubit | Favorites management |
| ReadingStatsCubit | Reading statistics |
| ReminderCubit | Daily reminders |
| SearchHistoryCubit | Search history management |
| LanguageCubit | Language switching (AR/EN) |

---

## المساهمة | Contributing

> **كل مساهمة = أجر صدقة جارية بإذن الله**
> **Every contribution = ongoing charity reward, God willing**

### كيف تساهم؟ | How to Contribute?

1. **Fork** the project
2. Create a new **Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Write **tests** first
4. Implement changes
5. Ensure tests pass
   ```bash
   flutter test
   flutter analyze
   ```
6. **Commit** changes
   ```bash
   git commit -m "feat: add amazing feature"
   ```
7. **Push** to branch
   ```bash
   git push origin feature/amazing-feature
   ```
8. Open **Pull Request**

### أفكار للمساهمة | Contribution Ideas

راجع [خطة التطوير](docs/IMPROVEMENT_PLAN.md) | See [Development Plan](docs/IMPROVEMENT_PLAN.md)

#### مكتمل | Completed
- [x] Unit tests (241 tests)
- [x] Improved search (debounce + Arabic normalization)
- [x] Accessibility labels
- [x] Error handling in data loading
- [x] Input validation
- [x] Favorites/bookmarks system
- [x] Reading statistics
- [x] Share as image
- [x] Daily hadith reminder
- [x] Focused reading mode
- [x] English language support
- [x] Search by hadith number
- [x] Search history

#### مميزات جديدة | New Features
- [ ] French language support
- [ ] Cloud sync
- [ ] Apple Watch app

#### تحسينات | Improvements
- [ ] Search performance
- [ ] Animations
- [ ] Better tablet support

---

## خارطة الطريق | Roadmap

### الإصدار 1.1 | Version 1.1 (Completed)
- [x] Favorites system
- [x] Improved search
- [x] Comprehensive tests
- [x] Reading statistics
- [x] Share as image

### الإصدار 1.2 | Version 1.2 (Current)
- [x] Daily reminders
- [x] Focused reading mode
- [x] English language support
- [x] Bilingual UI
- [x] Search by hadith number
- [x] Search history
- [x] 269 tests

### الإصدار 2.0 | Version 2.0
- [ ] Cloud sync
- [ ] French language
- [ ] Apple Watch app

---

## الترخيص | License

هذا المشروع مرخص تحت رخصة **MIT** - راجع ملف [LICENSE](LICENSE) للتفاصيل.

This project is licensed under the **MIT** License - see [LICENSE](LICENSE) for details.

الغرض الأساسي من المشروع هو **نشر العلم** ونيل **أجر الصدقة الجارية** بإذن الله.

The main purpose is to **spread knowledge** and earn **ongoing charity reward**, God willing.

---

## المطوّر | Developer

**[محمود حمدي | Mahmoud Hamdi](https://github.com/mahmoodhamdi)**

للتواصل والمساهمة | For contact and contribution:
- Open an [Issue](https://github.com/mahmoodhamdi/nawawi_40_hadith_app/issues)
- Or connect via GitHub

---

<div align="center">

**إذا أعجبك المشروع، لا تنسى إضافة نجمة** ⭐
**If you like the project, don't forget to add a star** ⭐

اللهم اجعل هذا العمل خالصًا لوجهك الكريم، وارزقنا به الأجر والمغفرة

O Allah, make this work sincere for Your noble sake, and grant us reward and forgiveness

</div>
