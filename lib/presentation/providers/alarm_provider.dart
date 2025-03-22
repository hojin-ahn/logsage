import 'package:flutter/material.dart';
import '../../domain/entities/alarm.dart';

class AlarmProvider with ChangeNotifier {
  List<Alarm> _alarms = [];

  List<Alarm> get alarms => _alarms;

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    notifyListeners();
  }

  void removeAlarm(int id) {
    _alarms.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleAlarm(int id, bool enabled) {
    _alarms = _alarms.map((a) {
      if (a.id == id) {
        return Alarm(
          id: a.id,
          time: a.time,
          days: a.days,
          isEnabled: enabled,
        );
      }
      return a;
    }).toList();
    notifyListeners();
  }
}
