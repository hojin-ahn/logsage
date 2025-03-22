import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/alarm.dart';
import '../../presentation/pages/alarm_ringing_page.dart';

class AlarmChecker {
  static Timer? _timer;

  static void start(BuildContext context, List<Alarm> alarms) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      final now = TimeOfDay.now();
      final today = DateTime.now().weekday % 7;

      for (var alarm in alarms) {
        if (!alarm.isEnabled) continue;

        if (!alarm.days.contains(today)) continue;

        if (alarm.time.hour == now.hour && alarm.time.minute == now.minute) {
          Logger.log("[INFO] Triggering alarm ${alarm.id}");
          _timer?.cancel();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AlarmRingingPage(alarmId: alarm.id),
            ),
          );

          break;
        }
      }
    });

    Logger.log("[INFO] AlarmChecker started");
  }

  static void stop() {
    _timer?.cancel();
    Logger.log("[INFO] AlarmChecker stopped");
  }
}
