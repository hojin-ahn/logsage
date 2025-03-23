import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'logger.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize({Function(int)? onNotificationTap}) async {
    tzData.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && onNotificationTap != null) {
          final alarmId = int.tryParse(payload);
          if (alarmId != null) {
            onNotificationTap(alarmId);
          }
        }
      },
    );
  }

  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
  }) async {
    try {
      Logger.log('[NOTIFICATION] Scheduling alarm ID=$id at \$scheduledTime');
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel_id',
            'Alarms',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: id.toString(),
      );
      Logger.log('[NOTIFICATION] ✅ Alarm ID=$id scheduled successfully');
    } catch (e) {
      Logger.log('[NOTIFICATION] ❌ Failed to schedule alarm ID=$id: \$e');
    }
  }

  static Future<void> cancelAlarm(int id) async {
    await _notificationsPlugin.cancel(id);
    Logger.log('[NOTIFICATION] Cancelled alarm ID=$id');
  }
}
