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
}
