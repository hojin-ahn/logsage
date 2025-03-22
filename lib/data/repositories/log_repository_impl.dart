import '../../domain/entities/log_analysis_result.dart';
import '../../domain/repositories/log_repository.dart';
import '../datasources/log_remote_datasource.dart';

class LogRepositoryImpl implements LogRepository {
  final LogRemoteDataSource remoteDataSource;

  LogRepositoryImpl(this.remoteDataSource);

  @override
  Future<LogAnalysisResult> analyzeLogs(List<String> logs) async {
    final summary = await remoteDataSource.analyzeLogsRemotely(logs);
    return LogAnalysisResult(summary: summary);
  }
}
