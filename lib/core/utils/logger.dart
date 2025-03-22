class Logger {
  static final List<String> _logBuffer = [];

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
}
