import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../features/models/model/task_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _plugin.initialize(settings);
  }

  static Future<void> scheduleNotificationForTask(TaskModel task) async {
    if (task.id == null) return;
    final id = task.id!;
    // schedule 10 minutes before due date (or immediate if past)
    final scheduled = task.dueDate.subtract(const Duration(minutes: 10));
    final tzDate = tz.TZDateTime.from(scheduled.isAfter(DateTime.now()) ? scheduled : DateTime.now().add(const Duration(seconds: 5)), tz.local);

    final androidDetails = AndroidNotificationDetails('tasks_channel', 'Tasks', channelDescription: 'Reminders for tasks', importance: Importance.max, priority: Priority.high);
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      'Reminder: ${task.title}',
      task.description ?? 'You have a task due at ${task.dueDate}',
      tzDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
