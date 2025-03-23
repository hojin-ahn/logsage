import 'package:flutter/material.dart';

class Alarm {
  final int id;
  final TimeOfDay time;
  final List<int> days;
  final bool isEnabled;

  Alarm({
    required this.id,
    required this.time,
    required this.days,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': time.hour,
      'minute': time.minute,
      'days': days,
      'enabled': isEnabled,
    };
  }

  static Alarm fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      days: List<int>.from(json['days']),
      isEnabled: json['enabled'],
    );
  }
}
