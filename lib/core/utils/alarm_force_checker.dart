import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/alarm.dart';
import '../../presentation/pages/alarm_ringing_page.dart';
import 'notification_router.dart';
import 'logger.dart';

class AlarmForceChecker {
  static Timer? _timer;

  static void start(BuildContext context, List<Alarm> alarms) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      final now = tz.TZDateTime.now(tz.local);
      final nowHour = now.hour;
      final nowMinute = now.minute;
      final today = now.weekday % 7;

      for (final alarm in alarms) {
        if (!alarm.isEnabled) continue;
        if (!alarm.days.contains(today)) continue;

        if (alarm.time.hour == nowHour && alarm.time.minute == nowMinute) {
          final key =
              'force_triggered_\${alarm.id}_\${now.year}_\${now.month}_\${now.day}_\${nowHour}_\${nowMinute}';
          Logger.log(
              '[DEBUG] Checking alarm \${alarm.id} for $today at \$nowHour:\$nowMinute');

          if (!_triggeredKeys.contains(key)) {
            _triggeredKeys.add(key);

            Logger.log('[INFO] Forcing alarm ring: id=\${alarm.id}');
            Navigator.of(NotificationRouter.navigatorKey.currentContext!).push(
              MaterialPageRoute(
                builder: (_) {
                  Logger.log(
                      '[INFO] Showing AlarmRingingPage for forced alarm');
                  return AlarmRingingPage(alarmId: alarm.id);
                },
              ),
            );
          }
        }
      }
    });
  }

  static final Set<String> _triggeredKeys = {};

  static void stop() {
    _timer?.cancel();
  }
}
