# خطة تنفيذ التذكيرات اليومية

## نظرة عامة
إضافة نظام تذكيرات يومية لتنبيه المستخدم بقراءة حديث جديد يومياً.

---

## المتطلبات الوظيفية

### 1. إعدادات التذكير
- تفعيل/إلغاء التذكير اليومي
- اختيار وقت التذكير (الافتراضي: 8:00 صباحاً)
- عرض حالة التذكير الحالية

### 2. الإشعارات
- إشعار يومي في الوقت المحدد
- عنوان: "حديث اليوم"
- محتوى: اسم أو جزء من الحديث التالي غير المقروء
- عند الضغط: فتح التطبيق على الحديث

---

## الهيكل التقني

### الحزم المطلوبة
```yaml
dependencies:
  flutter_local_notifications: ^18.0.1
  timezone: ^0.10.0
```

### الملفات الجديدة
```
lib/
├── cubit/
│   ├── reminder_cubit.dart
│   └── reminder_state.dart
├── services/
│   └── notification_service.dart
└── screens/
    └── settings_screen.dart (جديد)
```

---

## التنفيذ

### 1. NotificationService (lib/services/notification_service.dart)
```dart
class NotificationService {
  // تهيئة الإشعارات
  static Future<void> initialize();

  // جدولة تذكير يومي
  static Future<void> scheduleDailyReminder(TimeOfDay time, String title, String body);

  // إلغاء التذكير
  static Future<void> cancelReminder();

  // طلب الصلاحيات
  static Future<bool> requestPermissions();

  // التحقق من حالة الصلاحيات
  static Future<bool> hasPermissions();
}
```

### 2. ReminderState (lib/cubit/reminder_state.dart)
```dart
class ReminderState extends Equatable {
  final bool isEnabled;
  final TimeOfDay reminderTime;
  final bool isLoading;
  final bool hasPermission;

  // الوقت الافتراضي: 8:00 صباحاً
  static const defaultTime = TimeOfDay(hour: 8, minute: 0);
}
```

### 3. ReminderCubit (lib/cubit/reminder_cubit.dart)
```dart
class ReminderCubit extends Cubit<ReminderState> {
  // تحميل الإعدادات المحفوظة
  Future<void> loadSettings();

  // تفعيل/إلغاء التذكير
  Future<void> toggleReminder();

  // تغيير وقت التذكير
  Future<void> setReminderTime(TimeOfDay time);

  // طلب الصلاحيات
  Future<void> requestPermissions();
}
```

### 4. شاشة الإعدادات (lib/screens/settings_screen.dart)
- قسم التذكيرات
  - Switch لتفعيل/إلغاء
  - اختيار الوقت (TimePicker)
  - عرض حالة الصلاحيات

---

## إعداد Android

### AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

---

## إعداد iOS

### Info.plist
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## مفاتيح التخزين (SharedPreferences)
```dart
class ReminderKeys {
  static const String isEnabled = 'reminder_enabled';
  static const String hour = 'reminder_hour';
  static const String minute = 'reminder_minute';
}
```

---

## خطوات التنفيذ

### المرحلة 1: الإعداد الأساسي
1. إضافة الحزم للـ pubspec.yaml
2. إعداد Android permissions
3. إنشاء NotificationService

### المرحلة 2: منطق التذكير
4. إنشاء ReminderState
5. إنشاء ReminderCubit
6. إضافة PreferencesService methods

### المرحلة 3: واجهة المستخدم
7. إنشاء شاشة الإعدادات
8. إضافة زر الإعدادات في الشاشة الرئيسية
9. ربط كل شيء في main.dart

### المرحلة 4: الاختبارات
10. اختبارات ReminderState
11. اختبارات ReminderCubit
12. اختبارات NotificationService

---

## تجربة المستخدم

### السيناريو الأول: تفعيل التذكير
1. المستخدم يفتح الإعدادات
2. يضغط على "تفعيل التذكير اليومي"
3. يُطلب منه السماح بالإشعارات (إذا لم يسمح مسبقاً)
4. يختار الوقت المناسب
5. يظهر تأكيد بنجاح التفعيل

### السيناريو الثاني: استلام التذكير
1. في الوقت المحدد يظهر إشعار
2. عنوان: "حان وقت حديث اليوم"
3. محتوى: "الحديث رقم X - [جزء من الحديث]"
4. عند الضغط: فتح التطبيق على الحديث

---

## نص الإشعار
```dart
const reminderTitle = 'حان وقت حديث اليوم';
String reminderBody(int hadithNumber) => 'الحديث رقم $hadithNumber من الأربعين النووية';
```

---

## التبعيات على الكود الموجود
- `ReadingStatsCubit`: لمعرفة الحديث التالي غير المقروء
- `HadithCubit`: للحصول على بيانات الحديث
- `PreferencesService`: لحفظ إعدادات التذكير
