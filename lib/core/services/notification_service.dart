import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:meal_box/core/utils/time_location_utils.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data; // ← separate alias
import 'package:timezone/timezone.dart' as tz;
// ← separate alias

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  final now = DateTime.now();

  // ─────────────────────────────────────────────
  // Initialize
  // ─────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    final String currentTimeZone = await DeviceTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'meal_reminders_channel',
      'Meal Reminders',
      description: 'Daily meal reminder notifications',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;

    log(
      'NotificationService initialized. Timezone: $currentTimeZone',
      name: 'NotificationService',
    );
  }

  // ─────────────────────────────────────────────
  // Request Permission
  // ─────────────────────────────────────────────

  Future<bool> requestPermission() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();

    await androidImplementation?.requestExactAlarmsPermission();

    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();

      return status.isGranted;
    }

    if (await Permission.notification.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────
  // Schedule All Meal Notifications
  // ─────────────────────────────────────────────

  Future<void> scheduleAllMealNotifications({
    required String breakfastRecipeName,
    required String lunchRecipeName,
    required String dinnerRecipeName,
  }) async {
    await _plugin.cancelAll();

    await _scheduleMealNotification(
      mealTime: MealTime.breakfast,
      recipeName: breakfastRecipeName,
    );

    await _scheduleMealNotification(
      mealTime: MealTime.lunch,
      recipeName: lunchRecipeName,
    );

    await _scheduleMealNotification(
      mealTime: MealTime.dinner,
      recipeName: dinnerRecipeName,
    );

    log(
      'All meal notifications scheduled successfully',
      name: 'NotificationService',
    );
  }

  // ─────────────────────────────────────────────
  // Schedule Individual Meal Notification
  // ─────────────────────────────────────────────

  Future<void> _scheduleMealNotification({
    required MealTime mealTime,
    required String recipeName,
  }) async {
    final label = TimeUtils.mealTimeLabel(mealTime);

    final emoji = TimeUtils.mealTimeEmoji(mealTime);

    await _scheduleDaily(
      id: TimeUtils.notificationId(mealTime),
      title: '$emoji $label Time',
      body: 'Try making $recipeName today.',
      hour: TimeUtils.notificationHour(mealTime),
      minute: TimeUtils.notificationMinute(mealTime),
    );
  }

  // ─────────────────────────────────────────────
  // Internal: Schedule Daily
  // ─────────────────────────────────────────────

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Prevent same-minute timing issue
      if (scheduledDate.isBefore(now.add(const Duration(seconds: 5)))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      log('NOW: $now', name: 'NotificationService');

      log('SCHEDULED: $scheduledDate', name: 'NotificationService');

      const NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders_channel_v2',
          'Meal Reminders',
          channelDescription: 'Daily meal reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/messenger',
          playSound: true,
          sound: RawResourceAndroidNotificationSound('eat'),
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      log('SCHEDULE SUCCESS — id: $id', name: 'NotificationService');
    } catch (e) {
      log('SCHEDULE ERROR: $e', name: 'NotificationService');
    }
  }

  // ─────────────────────────────────────────────
  // Immediate Notification
  // ─────────────────────────────────────────────

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders_channel_v2',
          'Meal Reminders',
          channelDescription: 'Daily meal reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/messenger',
          playSound: true,
          sound: RawResourceAndroidNotificationSound('eat'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Cancel Notifications
  // ─────────────────────────────────────────────

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();

    log('All notifications cancelled', name: 'NotificationService');
  }

  // ─────────────────────────────────────────────
  // Notification Tap Callback
  // ─────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    log(
      'Notification tapped — id: ${response.id}, payload: ${response.payload}',
      name: 'NotificationService',
    );
  }
}
