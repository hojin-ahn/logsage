import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

class LogAnalyzerPage extends StatelessWidget {
  const LogAnalyzerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LogProvider>(context);
    final result = provider.result;
    final isLoading = provider.isLoading;
    final error = provider.error;

    return Scaffold(
      appBar: AppBar(title: const Text('LOG ANALYSIS REPORT')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Text(
                      'ERROR: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : result == null
                    ? const Center(
                        child:
                            Text('There is no log analysis report available.'))
                    : _buildResultView(context, result.summary, provider),
      ),
    );
  }

  Widget _buildResultView(
      BuildContext context, String summary, LogProvider provider) {
    final lines =
        summary.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: lines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child:
                      Text(lines[index], style: const TextStyle(fontSize: 16)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton.icon(
            onPressed: () => provider.analyze(),
            icon: const Icon(Icons.refresh),
            label: const Text('REANALYSIS'),
          ),
        )
      ],
    );
  }
}
