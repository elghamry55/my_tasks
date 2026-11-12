
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../features/models/model/task_model.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iOS = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: iOS,
    );

    await _plugin.initialize(settings);
  }

  static Future<void> scheduleNotificationForTask(
      TaskModel task,
      ) async {
    if (task.id == null || task.status == 1) return;

    // Cancel previous notification before scheduling.
    await cancelNotification(task.id!);

    final scheduled = task.dueDate.subtract(
      const Duration(minutes: 10),
    );

    final now = DateTime.now();

    final notificationTime = scheduled.isAfter(now)
        ? scheduled
        : now.add(const Duration(seconds: 5));

    final tzDate = tz.TZDateTime.from(
      notificationTime,
      tz.local,
    );

    const androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'Tasks',
      channelDescription: 'Reminders for your tasks',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      task.id!,
      'Reminder: ${task.title}',
      task.description?.isNotEmpty == true
          ? task.description!
          : 'You have a task due at ${task.dueDate}',
      tzDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
