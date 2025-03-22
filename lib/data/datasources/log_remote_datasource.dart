import 'dart:convert';
import 'package:http/http.dart' as http;

class LogRemoteDataSource {
  final String baseUrl;

  LogRemoteDataSource(this.baseUrl);

  Future<String> analyzeLogsRemotely(List<String> logs) async {
    final url = Uri.parse('$baseUrl/analyze');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'logs': logs.join('\n')}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['summary'] as String;
    } else {
      throw Exception('Failed to analyze logs');
    }
  }
}
