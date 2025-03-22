import '../entities/log_analysis_result.dart';

abstract class LogRepository {
  Future<LogAnalysisResult> analyzeLogs(List<String> logs);
}
