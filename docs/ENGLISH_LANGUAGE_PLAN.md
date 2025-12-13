# خطة دعم اللغة الإنجليزية
# English Language Support Plan

## نظرة عامة / Overview
إضافة دعم اللغة الإنجليزية مع إمكانية التبديل بين العربية والإنجليزية.
Add English language support with the ability to switch between Arabic and English.

---

## المتطلبات / Requirements

### 1. ترجمة الأحاديث / Hadith Translations
- إضافة ترجمات إنجليزية للأحاديث الأربعين
- Add English translations of the 40 hadiths
- ترجمات موثوقة من مصادر معتمدة
- Reliable translations from authentic sources

### 2. ترجمة واجهة المستخدم / UI Translations
- جميع النصوص في التطبيق
- All app strings and labels
- رسائل الخطأ والتنبيهات
- Error messages and notifications

### 3. التبديل بين اللغات / Language Switching
- إعداد في شاشة الإعدادات
- Setting in settings screen
- حفظ التفضيل في SharedPreferences
- Save preference in SharedPreferences

---

## الهيكل التقني / Technical Structure

### الملفات الجديدة / New Files
```
lib/
├── cubit/
│   ├── language_cubit.dart
│   └── language_state.dart
├── core/
│   └── l10n/
│       ├── app_localizations.dart
│       ├── strings_ar.dart
│       └── strings_en.dart
assets/
└── json/
    └── 40-hadith-nawawi-en.json
```

### تحديث الملفات / Updated Files
```
lib/models/hadith.dart           # Add English fields
lib/core/strings.dart            # Refactor for l10n
lib/main.dart                    # Add language provider
lib/screens/settings_screen.dart # Add language switcher
```

---

## خطوات التنفيذ / Implementation Steps

### المرحلة 1: إعداد البنية التحتية
1. إنشاء LanguageCubit و LanguageState
2. إضافة مفاتيح اللغة في PreferencesService
3. إنشاء ملف الترجمة الإنجليزية للواجهة

### المرحلة 2: ترجمة الأحاديث
4. إنشاء ملف JSON للأحاديث بالإنجليزية
5. تحديث نموذج Hadith لدعم اللغتين
6. تحديث HadithLoader لتحميل اللغة المناسبة

### المرحلة 3: تحديث الواجهة
7. تحديث شاشة الإعدادات لإضافة خيار اللغة
8. تحديث جميع الشاشات لاستخدام الترجمات
9. ضبط اتجاه النص (RTL/LTR)

### المرحلة 4: الاختبار والتوثيق
10. إضافة اختبارات للغة
11. تحديث README

---

## نموذج Hadith المحدث / Updated Hadith Model
```dart
class Hadith {
  final String hadithAr;
  final String hadithEn;
  final String descriptionAr;
  final String descriptionEn;

  String getHadith(String locale) => locale == 'en' ? hadithEn : hadithAr;
  String getDescription(String locale) => locale == 'en' ? descriptionEn : descriptionAr;
}
```

---

## LanguageState
```dart
enum AppLanguage { arabic, english }

class LanguageState extends Equatable {
  final AppLanguage language;
  final Locale locale;

  bool get isArabic => language == AppLanguage.arabic;
  bool get isEnglish => language == AppLanguage.english;
}
```

---

## مفاتيح التخزين / Storage Keys
```dart
class LanguageKeys {
  static const String language = 'app_language';
}
```

---

## تبعيات / Dependencies
لا حاجة لحزم إضافية - سنستخدم نظام Flutter المدمج
No additional packages needed - using Flutter's built-in system.
