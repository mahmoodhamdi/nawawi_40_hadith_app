import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/language_cubit.dart';
import '../../cubit/language_state.dart';

/// Localized strings for the app
class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  /// Get localizations from context
  static AppLocalizations of(BuildContext context) {
    final state = context.watch<LanguageCubit>().state;
    return AppLocalizations(state.language);
  }

  /// Get localizations without watching (for one-time access)
  static AppLocalizations read(BuildContext context) {
    final state = context.read<LanguageCubit>().state;
    return AppLocalizations(state.language);
  }

  bool get isArabic => language == AppLanguage.arabic;
  bool get isEnglish => language == AppLanguage.english;

  // App General
  String get appTitle => isArabic ? 'الأربعون النووية' : 'Forty Hadith Nawawi';
  String get welcome => isArabic
      ? 'وَما آتاكُمُ الرَّسُولُ فَخُذُوهُ\nوَما نَهاكُمْ عَنْهُ فَانْتَهُوا'
      : 'And whatever the Messenger gives you, take it\nAnd whatever he forbids you, abstain from it';
  String get searchHint => isArabic ? 'ابحث عن حديث...' : 'Search for hadith...';
  String get noResults => isArabic ? 'لا يوجد نتائج للبحث.' : 'No search results found.';

  // Search History
  String get searchHistory => isArabic ? 'سجل البحث' : 'Search History';
  String get clearHistory => isArabic ? 'مسح الكل' : 'Clear All';
  String get noSearchHistory => isArabic ? 'لا يوجد سجل بحث' : 'No search history';
  String get recentSearches => isArabic ? 'عمليات البحث الأخيرة' : 'Recent Searches';
  String get searchByNumber => isArabic ? 'بحث برقم الحديث' : 'Search by hadith number';

  // Hadith
  String get hadithNumber => isArabic ? 'الحديث رقم' : 'Hadith No.';
  String get explanation => isArabic ? 'الشرح:' : 'Explanation:';
  String hadithTitle(int number) => isArabic ? 'الحديث $number' : 'Hadith $number';

  // Sharing
  String get share => isArabic ? 'مشاركة' : 'Share';
  String get shareHadithOnly => isArabic ? 'مشاركة الحديث فقط' : 'Share hadith only';
  String get shareDescriptionOnly => isArabic ? 'مشاركة الشرح فقط' : 'Share explanation only';
  String get shareBoth => isArabic ? 'مشاركة الحديث مع الشرح' : 'Share hadith with explanation';
  String get shareAsImage => isArabic ? 'مشاركة كصورة' : 'Share as image';
  String get selectTheme => isArabic ? 'اختر الثيم' : 'Select theme';

  // Audio Player
  String get play => isArabic ? 'تشغيل الصوت' : 'Play audio';
  String get pause => isArabic ? 'إيقاف الصوت' : 'Pause audio';
  String get replay => isArabic ? 'إعادة' : 'Replay';
  String get skipForward => isArabic ? 'تقديم 10 ثواني' : 'Forward 10s';
  String get skipBackward => isArabic ? 'رجوع 10 ثواني' : 'Rewind 10s';
  String get playbackSpeed => isArabic ? 'سرعة التشغيل' : 'Playback speed';

  // Reading Progress
  String get continueReading => isArabic ? 'متابعة القراءة' : 'Continue Reading';
  String get lastRead => isArabic ? 'آخر قراءة' : 'Last read';
  String get completed => isArabic ? 'مكتمل' : 'Completed';
  String get readingProgress => isArabic ? 'تقدم القراءة' : 'Reading Progress';
  String get hadithsRead => isArabic ? 'أحاديث مقروءة' : 'Hadiths read';
  String get remaining => isArabic ? 'متبقي' : 'Remaining';
  String get markAsRead => isArabic ? 'تحديد كمقروء' : 'Mark as read';
  String get markAsUnread => isArabic ? 'تحديد كغير مقروء' : 'Mark as unread';

  // Favorites
  String get favorites => isArabic ? 'المفضلة' : 'Favorites';
  String get allHadiths => isArabic ? 'كل الأحاديث' : 'All Hadiths';
  String get addToFavorites => isArabic ? 'إضافة للمفضلة' : 'Add to favorites';
  String get removeFromFavorites => isArabic ? 'إزالة من المفضلة' : 'Remove from favorites';
  String get noFavorites => isArabic ? 'لا توجد أحاديث مفضلة' : 'No favorite hadiths';

  // Settings
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get languageLabel => isArabic ? 'اللغة' : 'Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get theme => isArabic ? 'المظهر' : 'Theme';
  String get lightTheme => isArabic ? 'فاتح' : 'Light';
  String get darkTheme => isArabic ? 'داكن' : 'Dark';
  String get systemTheme => isArabic ? 'النظام' : 'System';
  String get blueTheme => isArabic ? 'أزرق' : 'Blue';
  String get purpleTheme => isArabic ? 'بنفسجي' : 'Purple';

  // Daily Reminder
  String get dailyReminder => isArabic ? 'التذكير اليومي' : 'Daily Reminder';
  String get dailyReminderDescription => isArabic
      ? 'تذكير يومي لقراءة حديث من الأربعين النووية'
      : 'Daily reminder to read a hadith from the Forty Nawawi';
  String get reminderTime => isArabic ? 'وقت التذكير' : 'Reminder time';
  String get reminderEnabled => isArabic ? 'التذكير مفعّل' : 'Reminder enabled';
  String get reminderDisabled => isArabic ? 'التذكير معطّل' : 'Reminder disabled';
  String get permissionRequired => isArabic ? 'يرجى السماح بالإشعارات' : 'Please allow notifications';
  String get permissionDenied => isArabic ? 'تم رفض صلاحية الإشعارات' : 'Notification permission denied';
  String get selectTime => isArabic ? 'اختر الوقت' : 'Select time';
  String get allowPermission => isArabic ? 'السماح' : 'Allow';

  // Time
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get am => isArabic ? 'صباحاً' : 'AM';
  String get pm => isArabic ? 'مساءً' : 'PM';
  String minutesAgo(int minutes) => isArabic ? 'منذ $minutes دقيقة' : '$minutes minutes ago';
  String hoursAgo(int hours) => isArabic ? 'منذ $hours ساعة' : '$hours hours ago';
  String daysAgo(int days) => isArabic ? 'منذ $days يوم' : '$days days ago';
  String get justNow => isArabic ? 'الآن' : 'Just now';

  // Navigation
  String get next => isArabic ? 'التالي' : 'Next';
  String get previous => isArabic ? 'السابق' : 'Previous';
  String get nextHadith => isArabic ? 'الحديث التالي' : 'Next hadith';
  String get previousHadith => isArabic ? 'الحديث السابق' : 'Previous hadith';

  // Focused Reading
  String get focusedReading => isArabic ? 'وضع القراءة المركز' : 'Focused Reading';
  String get tapToShowControls => isArabic ? 'انقر لإظهار عناصر التحكم' : 'Tap to show controls';
  String get swipeToNavigate => isArabic ? 'اسحب للتنقل' : 'Swipe to navigate';

  // Font Size
  String get fontSize => isArabic ? 'حجم الخط' : 'Font size';
  String get hadithFontSize => isArabic ? 'حجم خط الحديث' : 'Hadith font size';
  String get descriptionFontSize => isArabic ? 'حجم خط الشرح' : 'Explanation font size';

  // Errors
  String get error => isArabic ? 'خطأ' : 'Error';
  String get loadingError => isArabic ? 'حدث خطأ أثناء التحميل' : 'An error occurred while loading';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';

  // About
  String get aboutApp => isArabic ? 'عن التطبيق' : 'About App';
  String get version => isArabic ? 'الإصدار' : 'Version';
  String get developer => isArabic ? 'المطور' : 'Developer';
  String get reciter => isArabic ? 'القارئ' : 'Reciter';
  String get sheikhAhmadAlNafees => isArabic ? 'الشيخ أحمد النفيس' : 'Sheikh Ahmad Al-Nafees';
}
