// === lib/core/utils/logger.dart ===

import 'dart:async';

class Logger {
  static final List<String> _logBuffer = [];
  static Timer? _uploadTimer;

  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final entry = '[$timestamp] $message';
    _logBuffer.add(entry);
    print(entry);
  }

  static List<String> get logs => List.unmodifiable(_logBuffer);

  static void clear() {
    _logBuffer.clear();
  }

  static void scheduleAutoUpload(Future<void> Function() onUpload) {
    _uploadTimer?.cancel();
    _uploadTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (_logBuffer.isNotEmpty) {
        await onUpload();
        clear();
      }
    });
  }

  static void stopAutoUpload() {
    _uploadTimer?.cancel();
  }
}
