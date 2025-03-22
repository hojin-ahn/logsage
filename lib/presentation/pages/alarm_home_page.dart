import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/logger.dart';
import '../providers/alarm_provider.dart';
import '../pages/log_analyzer_page.dart';
import '../../domain/entities/alarm.dart';

class AlarmHomePage extends StatelessWidget {
  const AlarmHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AlarmProvider>(context);
    final alarms = provider.alarms;

    return Scaffold(
      appBar: AppBar(title: const Text('🕒 Setting an alarm')),
      body: Column(
        children: [
          Expanded(
            child: alarms.isEmpty
                ? const Center(child: Text('No Alarm has been set'))
                : ListView.builder(
                    itemCount: alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = alarms[index];
                      final timeText = alarm.time.format(context);
                      final daysText = _daysToString(alarm.days);

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('$timeText'),
                          subtitle: Text('Days of the week: $daysText'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: alarm.isEnabled,
                                onChanged: (v) {
                                  Logger.log(
                                      "[INFO] Alarm ${alarm.id} toggled to $v");
                                  provider.toggleAlarm(alarm.id, v);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  Logger.log(
                                      "[INFO] Alarm ${alarm.id} deleted");
                                  provider.removeAlarm(alarm.id);
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          ElevatedButton(
            onPressed: () => _openAddAlarmDialog(context),
            child: const Text('Adding Alarm'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LogAnalyzerPage()),
            ),
            child: const Text('Log Analysis Summary'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _openAddAlarmDialog(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    final selectedDays = await showDialog<List<int>>(
      context: context,
      builder: (_) => _WeekdayPickerDialog(),
    );

    if (selectedDays == null || selectedDays.isEmpty) return;

    final provider = Provider.of<AlarmProvider>(context, listen: false);
    final newId = DateTime.now().millisecondsSinceEpoch;

    final newAlarm = Alarm(
      id: newId,
      time: selectedTime,
      days: selectedDays,
    );

    Logger.log("[INFO] New alarm added: $selectedTime / days: $selectedDays");

    provider.addAlarm(newAlarm);
  }

  String _daysToString(List<int> days) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days.map((d) => labels[d]).join(', ');
  }
}

class _WeekdayPickerDialog extends StatefulWidget {
  @override
  State<_WeekdayPickerDialog> createState() => _WeekdayPickerDialogState();
}

class _WeekdayPickerDialogState extends State<_WeekdayPickerDialog> {
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return AlertDialog(
      title: const Text('Days of the week for your alarm'),
      content: Wrap(
        spacing: 10,
        children: List.generate(7, (i) {
          return FilterChip(
            label: Text(labels[i]),
            selected: _selected.contains(i),
            onSelected: (v) {
              setState(() {
                if (v) {
                  _selected.add(i);
                } else {
                  _selected.remove(i);
                }
              });
            },
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _selected.toList()),
          child: const Text('Confirm'),
        )
      ],
    );
  }
}
