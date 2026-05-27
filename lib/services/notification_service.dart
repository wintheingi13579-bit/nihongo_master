// =============================================================
// notification_service.dart - Motivational daily reminders
// =============================================================
// We schedule a local notification (no internet needed) at 20:00
// every day to keep the streak alive.
// =============================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    await scheduleDaily();
  }

  Future<void> scheduleDaily() async {
    const android = AndroidNotificationDetails(
      'daily',
      'Daily reminders',
      channelDescription: 'Keep your Japanese streak alive 🔥',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await _plugin.show(
      0,
      'がんばって！ Time to study',
      'Tap to learn a new word and keep your streak alive 🔥',
      const NotificationDetails(android: android),
    );
  }
}
