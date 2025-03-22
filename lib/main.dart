// === lib/main.dart ===

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/utils/alarm_checker.dart';
import 'data/datasources/log_remote_datasource.dart';
import 'data/repositories/log_repository_impl.dart';
import 'domain/usecases/analyze_logs.dart';
import 'presentation/pages/alarm_home_page.dart';
import 'presentation/providers/alarm_provider.dart';
import 'presentation/providers/log_provider.dart';

void main() {
  final logDataSource =
      LogRemoteDataSource('https://logsage-backend.onrender.com');
  final logRepository = LogRepositoryImpl(logDataSource);
  final analyzeLogsUseCase = AnalyzeLogs(logRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(create: (_) => LogProvider(analyzeLogsUseCase)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
      AlarmChecker.start(context, alarmProvider.alarms);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogSage Alarm',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const AlarmHomePage(),
    );
  }
}
