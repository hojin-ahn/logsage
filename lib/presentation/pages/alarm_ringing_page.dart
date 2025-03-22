import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../core/utils/logger.dart';

class AlarmRingingPage extends StatefulWidget {
  final int alarmId;

  const AlarmRingingPage({super.key, required this.alarmId});

  @override
  State<AlarmRingingPage> createState() => _AlarmRingingPageState();
}

class _AlarmRingingPageState extends State<AlarmRingingPage> {
  late int a;
  late int b;
  int _remainingSeconds = 60;

  final _controller = TextEditingController();
  String? _errorText;

  final AudioPlayer _player = AudioPlayer();
  Timer? _timeoutTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
    _playAlarmSound();
    _startTimeoutTimer();
    Logger.log("[INFO] Alarm ${widget.alarmId} is ringing with math challenge");
  }

  @override
  void dispose() {
    _stopAlarmSound();
    _timeoutTimer?.cancel();
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _generateNewProblem() {
    final rng = Random();
    a = 100 + rng.nextInt(900);
    b = 100 + rng.nextInt(900);
  }

  void _playAlarmSound() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/alarm.mp3'));
    Logger.log("[INFO] Alarm sound started");
  }

  void _stopAlarmSound() async {
    await _player.stop();
    Logger.log("[INFO] Alarm sound stopped");
  }

  void _startTimeoutTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
    });

    _timeoutTimer = Timer(const Duration(seconds: 60), () {
      Logger.log(
          "[ERROR] Alarm ${widget.alarmId} auto-dismissed due to timeout");
      _stopAlarmSound();
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _checkAnswer() {
    final answer = int.tryParse(_controller.text.trim());
    final correct = a + b;

    if (answer == correct) {
      Logger.log(
          "[INFO] Alarm ${widget.alarmId} dismissed with correct answer: $a + $b = $answer");
      _stopAlarmSound();
      _timeoutTimer?.cancel();
      _countdownTimer?.cancel();
      Navigator.of(context).pop();
    } else {
      Logger.log(
          "[WARNING] Incorrect answer for alarm ${widget.alarmId}: entered $answer, expected $correct");
      setState(() {
        _errorText = 'Wrong! Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dangerColor = _remainingSeconds <= 15
        ? Colors.red[700]
        : (_remainingSeconds <= 30 ? Colors.orange[600] : Colors.green[600]);

    return Scaffold(
      backgroundColor: dangerColor!.withOpacity(0.1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 타이머 표시
              Text(
                'Remaining Time (s): $_remainingSeconds',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: dangerColor,
                ),
              ),
              const SizedBox(height: 24),

              // 문제
              Expanded(
                child: Center(
                  child: Text(
                    '$a + $b = ?',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // 입력창
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'ANSWER',
                  errorText: _errorText,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
                onSubmitted: (_) => _checkAnswer(),
              ),

              const SizedBox(height: 16),

              // 제출 버튼
              ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('SUBMIT', style: TextStyle(fontSize: 20)),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
