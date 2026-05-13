import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for handling local notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'hadith_reminder_channel';
  static const String _channelName = 'تذكير الحديث اليومي';
  static const String _channelDescription =
      'تذكيرات يومية لقراءة الأحاديث النووية';
  static const int _dailyNotificationId = 1;
  // Distinct notification IDs so the standard daily reminder and the
  // Friday special can coexist without overwriting each other.
  static const int _jumuahNotificationId = 2;

  /// Initialize the notification service
  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS/macOS initialization settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialize with settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // The app will open to the home screen by default
    // Payload can be used to navigate to specific hadith
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    // Android 13+ permissions
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS permissions
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Check if notifications are permitted
  static Future<bool> hasPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final areEnabled = await androidPlugin.areNotificationsEnabled();
      return areEnabled ?? false;
    }

    // On iOS, we assume permissions if the plugin doesn't report otherwise
    return true;
  }

  /// Schedule a daily reminder at the specified time
  static Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Cancel any existing reminder first
    await cancelReminder();

    // Create notification details
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    // Calculate the next occurrence of the specified time
    final scheduledDate = _nextInstanceOfTime(time);

    // Schedule the notification
    await _notifications.zonedSchedule(
      _dailyNotificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('Daily reminder scheduled for ${time.hour}:${time.minute}');
  }

  /// Cancel the daily reminder
  static Future<void> cancelReminder() async {
    await _notifications.cancel(_dailyNotificationId);
    debugPrint('Daily reminder cancelled');
  }

  /// Schedule a recurring Friday-morning notification — used to highlight
  /// Friday-related hadiths (e.g. on the etiquette of Jumu'ah). Caller
  /// passes the local time-of-day to fire; the engine picks the next
  /// Friday at that time and `matchDateTimeComponents` repeats weekly.
  ///
  /// Cancellable independently of the daily reminder via [cancelJumuahReminder].
  static Future<void> scheduleJumuahReminder({
    required TimeOfDay time,
    required String title,
    required String body,
    String? payload,
  }) async {
    await cancelJumuahReminder();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final scheduledDate = _nextFridayAtTime(time);

    await _notifications.zonedSchedule(
      _jumuahNotificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // dayOfWeekAndTime so it repeats every Friday at the same time.
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
      'Jumu\'ah reminder scheduled for Friday ${time.hour}:${time.minute}',
    );
  }

  /// Cancel the Friday reminder without touching the daily one.
  static Future<void> cancelJumuahReminder() async {
    await _notifications.cancel(_jumuahNotificationId);
    debugPrint('Jumu\'ah reminder cancelled');
  }

  /// Heuristic local-time anchors used when the user chooses
  /// "after Fajr" or "before Maghrib" without configuring a precise time.
  /// We don't compute true astronomical prayer times (would require GPS
  /// or city DB; that's out of scope for an offline app) — these are
  /// conservative-but-useful approximations that the user can override.
  static const TimeOfDay afterFajrApprox = TimeOfDay(hour: 6, minute: 0);
  static const TimeOfDay afterDhuhrApprox = TimeOfDay(hour: 13, minute: 30);
  static const TimeOfDay afterAsrApprox = TimeOfDay(hour: 16, minute: 30);
  static const TimeOfDay beforeMaghribApprox = TimeOfDay(hour: 18, minute: 0);
  static const TimeOfDay afterIshaApprox = TimeOfDay(hour: 20, minute: 30);

  /// Compute the next Friday at [time] in the local timezone.
  static tz.TZDateTime _nextFridayAtTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    // DateTime.weekday: Monday=1, ..., Friday=5, Saturday=6, Sunday=7
    while (candidate.weekday != DateTime.friday || candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  /// Calculate the next instance of a given time
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Show an immediate notification (for testing)
  static Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.show(0, title, body, notificationDetails);
  }
}
