import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/utils/notification_helper.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/alarm.dart';

class AlarmProvider with ChangeNotifier {
  List<Alarm> _alarms = [];

  List<Alarm> get alarms => _alarms;

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmJsonList = _alarms.map((a) => a.toJson()).toList();
    await prefs.setString('alarms', jsonEncode(alarmJsonList));
  }

  Future<void> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('alarms');
    if (jsonString == null) return;

    final List<dynamic> jsonList = jsonDecode(jsonString);
    _alarms = jsonList.map((e) => Alarm.fromJson(e)).toList();

    for (final alarm in _alarms) {
      if (alarm.isEnabled) {
        await _scheduleNotificationForAlarm(alarm);
      }
    }

    notifyListeners();
  }

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    _scheduleNotificationForAlarm(alarm);
    _saveAlarms();
    notifyListeners();
  }

  void removeAlarm(int id) {
    _alarms.removeWhere((a) => a.id == id);
    NotificationHelper.cancelAlarm(id);
    _saveAlarms();
    notifyListeners();
  }

  void toggleAlarm(int id, bool enabled) {
    _alarms = _alarms.map((a) {
      if (a.id == id) {
        if (enabled) {
          _scheduleNotificationForAlarm(a);
        } else {
          NotificationHelper.cancelAlarm(id);
        }
        return Alarm(
          id: a.id,
          time: a.time,
          days: a.days,
          isEnabled: enabled,
        );
      }
      return a;
    }).toList();
    _saveAlarms();
    notifyListeners();
  }

  Future<void> _scheduleNotificationForAlarm(Alarm alarm) async {
    for (int weekday in alarm.days) {
      final now = tz.TZDateTime.now(tz.local);
      Logger.log('[DEBUG] Now = \$now, Alarm ID = \${alarm.id}');

      tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        alarm.time.hour,
        alarm.time.minute,
      );

      Logger.log(
          '[DEBUG] Initial scheduledTime = \$scheduledTime, weekday=$weekday');

      while (_toAppWeekday(scheduledTime.weekday) != weekday) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 7));
        Logger.log(
            '[DEBUG] Adjusted to future: scheduledTime = \$scheduledTime');
      }

      final prefs = await SharedPreferences.getInstance();
      final key =
          'triggered_\${alarm.id}_\${now.year}_\${now.month}_\${now.day}_\${alarm.time.hour}_\${alarm.time.minute}';
      final alreadyTriggered = prefs.getBool(key) ?? false;

      Logger.log(
          '[DEBUG] alreadyTriggered = \$alreadyTriggered for key: \$key');

      if (!alreadyTriggered) {
        await prefs.setBool(key, true);

        try {
          await NotificationHelper.scheduleAlarm(
            id: (alarm.id * 10 + weekday) % 1000000000,
            title: '⏰ Alarm',
            body: 'Time to wake up and solve your math problem!',
            scheduledTime: scheduledTime,
          );
          Logger.log(
              '[ALARM] ✅ Scheduled for \${scheduledTime.toIso8601String()}');
        } catch (e) {
          Logger.log('[ERROR] ❌ Failed to schedule alarm: \$e');
        }
      }
    }
  }

  int _toAppWeekday(int dartWeekday) {
    return dartWeekday % 7;
  }
}
