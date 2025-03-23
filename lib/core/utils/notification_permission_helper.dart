import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionHelper {
  static Future<void> requestNotificationPermissionIfNeeded() async {
    if (!Platform.isAndroid) return;

    final androidInfo = await Permission.notification.status;

    if (!androidInfo.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        debugPrint('[PERMISSION] Notification permission was denied.');
      } else {
        debugPrint('[PERMISSION] Notification permission granted.');
      }
    } else {
      debugPrint('[PERMISSION] Notification permission already granted.');
    }
  }
}
