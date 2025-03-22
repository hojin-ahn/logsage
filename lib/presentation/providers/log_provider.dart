import 'package:flutter/material.dart';
import '../../domain/entities/log_analysis_result.dart';
import '../../domain/usecases/analyze_logs.dart';
import '../../core/utils/logger.dart';

class LogProvider with ChangeNotifier {
  final AnalyzeLogs analyzeLogsUseCase;

  LogProvider(this.analyzeLogsUseCase);

  LogAnalysisResult? _result;
  bool _loading = false;
  String? _error;

  LogAnalysisResult? get result => _result;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<LogAnalysisResult?> analyze() async {
    if (Logger.logs.isEmpty) return null;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final logs = Logger.logs;
      final result = await analyzeLogsUseCase(logs);
      _result = result;
      Logger.clear();
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
