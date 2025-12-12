# خطة تطوير تطبيق الأربعين النووية

## تاريخ التحليل: 2025-12-13

---

## ملخص التحليل

| المقياس | القيمة |
|---------|--------|
| إجمالي ملفات Dart | 24 |
| إجمالي أسطر الكود | ~2,263 |
| تغطية الاختبارات | ضعيفة (اختبار واحد فقط) |
| تقييم جودة الكود | B- (جيد مع مشاكل ملحوظة) |

---

## 1. المشاكل الحرجة (يجب إصلاحها فوراً)

### 1.1 عدم وجود معالجة أخطاء في تحميل JSON
**الملف:** `lib/services/hadith_loader.dart`
```dart
// المشكلة: لا يوجد try-catch
final List<dynamic> jsonList = json.decode(jsonString);
```
**الحل:**
```dart
static Future<List<Hadith>> loadHadiths() async {
  try {
    final String jsonString = await rootBundle.loadString(
      'assets/json/40-hadith-nawawi.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => Hadith.fromJson(item)).toList();
  } on FormatException catch (e) {
    throw Exception('خطأ في تنسيق ملف البيانات: $e');
  } catch (e) {
    throw Exception('فشل تحميل الأحاديث: $e');
  }
}
```

### 1.2 معالجة DateTime بدون حماية
**الملف:** `lib/services/preferences_service.dart:27`
```dart
// المشكلة: قد يفشل DateTime.parse
return DateTime.parse(timeString);
```
**الحل:**
```dart
static Future<DateTime?> getLastReadTime() async {
  final prefs = await SharedPreferences.getInstance();
  final timeString = prefs.getString(lastReadTimeKey);
  if (timeString == null) return null;
  try {
    return DateTime.parse(timeString);
  } catch (e) {
    // إذا كانت البيانات تالفة، نمسحها
    await prefs.remove(lastReadTimeKey);
    return null;
  }
}
```

### 1.3 رقم الأحاديث مكتوب يدوياً
**الملف:** `lib/screens/hadith_details_screen.dart:324`
```dart
// المشكلة: الرقم 42 مكتوب يدوياً
onPressed: widget.index < 42 ? () => _navigateToNextHadith(context) : null,
```
**الحل:** استخدام طول القائمة الفعلي من HadithCubit

---

## 2. مشاكل الأداء

### 2.1 البحث غير محسّن
**الملف:** `lib/screens/home_screen.dart:417-425`
- البحث يتم على كل حرف بدون debounce
- البحث case-sensitive
- القائمة تُنشأ من جديد في كل مرة

**الحل:**
```dart
// إضافة debounce للبحث
Timer? _debounce;

void _onSearchChanged(String value) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 300), () {
    setState(() {
      _searchQuery = value.trim().toLowerCase();
    });
  });
}

// بحث غير حساس لحالة الأحرف
final filtered = _searchQuery.isEmpty
    ? state.hadiths
    : state.hadiths.where((h) =>
        h.hadith.toLowerCase().contains(_searchQuery) ||
        h.description.toLowerCase().contains(_searchQuery),
      ).toList();
```

### 2.2 إفراط في إرسال حالة الصوت
**الملف:** `lib/cubit/audio_player_cubit.dart:65-72`
- Stream الموضع يرسل تحديثات كثيرة جداً

**الحل:** استخدام throttle أو distinct

---

## 3. مشاكل إمكانية الوصول (Accessibility)

### 3.1 عدم وجود Semantic Labels
**الملفات المتأثرة:**
- `lib/widgets/hadith_tile.dart`
- `lib/widgets/audio_player_widget.dart`

**الحل:**
```dart
Semantics(
  label: 'الحديث رقم $index',
  child: InkWell(
    // ...
  ),
)
```

### 3.2 أزرار بدون tooltips
بعض الأزرار تفتقر إلى tooltip للمستخدمين

---

## 4. المميزات الناقصة

### 4.1 نظام المفضلة/الإشارات المرجعية
- لا يمكن للمستخدم حفظ أحاديث مفضلة
- فقط "آخر قراءة" موجود

**خطة التنفيذ:**
1. إضافة `FavoritesCubit`
2. تخزين قائمة المفضلة في SharedPreferences
3. إضافة أيقونة قلب في شاشة التفاصيل
4. إضافة تبويب للمفضلة في الشاشة الرئيسية

### 4.2 مشاركة متقدمة
- لا يوجد مشاركة كصورة
- لا يوجد نسخ للنص

### 4.3 تذكير يومي
- لا توجد إشعارات
- لا يوجد تذكير بحديث اليوم

### 4.4 وضع القراءة
- لا يوجد وضع قراءة مركز
- لا يوجد تمرير تلقائي مع الصوت

### 4.5 البحث المتقدم
- لا يوجد بحث برقم الحديث
- لا يوجد فلترة
- لا يوجد تاريخ بحث

### 4.6 الإحصائيات
- لا توجد إحصائيات قراءة
- لا يوجد تتبع للتقدم التفصيلي

### 4.7 دعم لغات إضافية
- التطبيق عربي فقط
- لا يوجد ترجمة للأحاديث

---

## 5. تحسينات الكود

### 5.1 فصل State من Cubit
**الملفات المتأثرة:**
- `lib/cubit/font_size_cubit.dart` - State مع Cubit في نفس الملف
- `lib/cubit/audio_player_cubit.dart` - State مع Cubit في نفس الملف

### 5.2 إنشاء ملف Constants
```dart
// lib/core/constants.dart
class AppConstants {
  static const int audioSkipSeconds = 10;
  static const double minFontSize = 12.0;
  static const double maxFontSize = 30.0;
  static const double fontSizeStep = 2.0;
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  static const Duration searchDebounce = Duration(milliseconds: 300);
}
```

### 5.3 توحيد النصوص
نقل كل النصوص المتكررة إلى `AppStrings`

---

## 6. خطة الاختبارات

### 6.1 اختبارات الوحدة (Unit Tests)
| الأولوية | الملف | نوع الاختبار |
|----------|--------|--------------|
| حرجة | `hadith_cubit_test.dart` | تحميل، أخطاء |
| حرجة | `audio_player_cubit_test.dart` | تشغيل، إيقاف، تقديم |
| عالية | `preferences_service_test.dart` | قراءة، كتابة |
| عالية | `theme_cubit_test.dart` | تبديل الثيمات |
| متوسطة | `font_size_cubit_test.dart` | زيادة، تقليل |
| متوسطة | `last_read_cubit_test.dart` | حفظ، استرجاع |

### 6.2 اختبارات التكامل
- تحميل التطبيق والتنقل
- تشغيل الصوت والتحكم
- البحث والفلترة
- تغيير الثيم

---

## 7. خطة التنفيذ (مرتبة حسب الأولوية)

### المرحلة 1: الإصلاحات الحرجة (أسبوع واحد)
- [ ] إضافة معالجة الأخطاء لـ JSON
- [ ] إصلاح DateTime parsing
- [ ] إزالة الأرقام المكتوبة يدوياً
- [ ] إضافة validation للمدخلات

### المرحلة 2: الأداء والجودة (أسبوعين)
- [ ] تحسين البحث (debounce + case-insensitive)
- [ ] تقليل تحديثات Stream
- [ ] فصل State من Cubit files
- [ ] إنشاء constants file

### المرحلة 3: الاختبارات (أسبوعين)
- [ ] كتابة Unit tests للـ Cubits
- [ ] كتابة Integration tests
- [ ] إعداد CI/CD للاختبارات

### المرحلة 4: إمكانية الوصول (أسبوع)
- [ ] إضافة Semantic labels
- [ ] إضافة tooltips متسقة
- [ ] تحسين تجربة لوحة المفاتيح

### المرحلة 5: المميزات الجديدة (شهر)
- [ ] نظام المفضلة
- [ ] التذكيرات اليومية
- [ ] البحث المتقدم
- [ ] الإحصائيات
- [ ] دعم لغات إضافية

---

## 8. مقارنة قبل وبعد

| الجانب | الحالي | المستهدف |
|--------|--------|----------|
| معالجة الأخطاء | ضعيفة | شاملة |
| تغطية الاختبارات | 5% | 80%+ |
| إمكانية الوصول | محدودة | متوافقة WCAG |
| الأداء | جيد | ممتاز |
| المميزات | أساسية | متقدمة |

---

## 9. كيفية المساهمة

1. اختر issue من القائمة
2. أنشئ branch جديد: `feature/issue-name`
3. اكتب الاختبارات أولاً (TDD)
4. نفذ الحل
5. تأكد من مرور جميع الاختبارات
6. افتح Pull Request

---

## 10. الموارد المفيدة

- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Accessibility in Flutter](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
