import 'dart:async';

/// AI Service stub — provides simple operations for the prototype.
/// In production, implement pluggable LLM clients, secure key storage, streaming responses and proper error handling.
class AIService {
  /// Summarize text. Returns a simple trimmed summary for the demo.
  Future<String> summarize(String text) async {
    final trimmed = text.replaceAll('\n', ' ').trim();
    if (trimmed.isEmpty) return 'No content to summarize.';
    // naive summary: first 150 chars
    await Future.delayed(const Duration(milliseconds: 300));
    return trimmed.length <= 150 ? trimmed : '${trimmed.substring(0, 150)}...';
  }

  /// Extract tasks (naive): returns lines starting with '-' or 'TODO'
  Future<List<String>> extractTasks(String text) async {
    final lines = text.split('\n').map((s) => s.trim()).where((s) => s.startsWith('-') || s.toLowerCase().startsWith('todo')).toList();
    await Future.delayed(const Duration(milliseconds: 300));
    return lines;
  }
}
