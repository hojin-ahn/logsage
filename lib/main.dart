import 'package:flutter/material.dart';
import 'package:logsage/core/utils/alarm_force_checker.dart';
import 'package:logsage/core/utils/exact_alarm_permission_helper.dart';
import 'package:logsage/core/utils/notification_permission_helper.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:logsage/core/utils/notification_helper.dart';
import 'package:logsage/core/utils/notification_router.dart';
import 'package:provider/provider.dart';

import 'data/datasources/log_remote_datasource.dart';
import 'data/repositories/log_repository_impl.dart';
import 'domain/usecases/analyze_logs.dart';
import 'presentation/pages/alarm_home_page.dart';
import 'presentation/providers/alarm_provider.dart';
import 'presentation/providers/log_provider.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(settings);
  tz.initializeTimeZones();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzData.initializeTimeZones();
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationPermissionHelper
          .requestNotificationPermissionIfNeeded();
      await ExactAlarmPermissionHelper.requestPermissionIfNeeded();
      final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
      await alarmProvider.loadAlarms();
      AlarmForceChecker.start(context, alarmProvider.alarms);

      await NotificationHelper.initialize(onNotificationTap: (alarmId) {
        NotificationRouter.handleTap(alarmId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationRouter.navigatorKey,
      title: 'LogSage Alarm',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const AlarmHomePage(),
    );
  }
}
