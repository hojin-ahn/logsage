import 'package:flutter/material.dart';
import '../../presentation/pages/alarm_ringing_page.dart';

class NotificationRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void handleTap(int alarmId) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AlarmRingingPage(alarmId: alarmId),
        ),
      );
    }
  }
}
