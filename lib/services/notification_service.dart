import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyNotificationId = 1;
  static const String _prefHour = 'notif_hour';
  static const String _prefMinute = 'notif_minute';
  static const String _prefEnabled = 'notif_enabled';

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(_dailyNotificationId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reading_channel',
      'Recordatorio de Lectura',
      channelDescription: 'Recordatorio diario para leer la Biblia',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _dailyNotificationId,
      '📖 Tiempo de leer la Biblia',
      '¡No olvides tu lectura de hoy! Mantén tu racha.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHour, hour);
    await prefs.setInt(_prefMinute, minute);
    await prefs.setBool(_prefEnabled, true);
  }

  Future<void> cancelReminder() async {
    await _plugin.cancel(_dailyNotificationId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, false);
  }

  Future<({bool enabled, TimeOfDay time})> getSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefEnabled) ?? false;
    final hour = prefs.getInt(_prefHour) ?? 7;
    final minute = prefs.getInt(_prefMinute) ?? 0;
    return (enabled: enabled, time: TimeOfDay(hour: hour, minute: minute));
  }
}
