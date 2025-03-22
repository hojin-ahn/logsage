import '../entities/log_analysis_result.dart';
import '../repositories/log_repository.dart';

class AnalyzeLogs {
  final LogRepository repository;

  AnalyzeLogs(this.repository);

  Future<LogAnalysisResult> call(List<String> logs) {
    return repository.analyzeLogs(logs);
  }
}
