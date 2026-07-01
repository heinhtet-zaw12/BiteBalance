import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bite_balance/core/errors/failures.dart';

/// Client that wraps multiple GenerativeModel instances and rotates
/// through them on quota errors (429 / "Quota exceeded") and retries
/// on transient errors (503 / UNAVAILABLE).
class GeminiClient {
  final List<GenerativeModel> _models;
  int _currentIndex = 0;

  static const _maxRetries = 3;
  static const _baseDelay = Duration(seconds: 1);

  /// Creates a GeminiClient with a list of API keys.
  /// At least one non-empty key is required.
  GeminiClient(List<String> apiKeys)
      : _models = apiKeys
            .where((key) => key.isNotEmpty)
            .map((key) => GenerativeModel(
                  model: 'gemini-2.5-flash',
                  apiKey: key,
                ))
            .toList() {
    if (_models.isEmpty) {
      throw ArgumentError('At least one API key is required');
    }
  }

  /// Generates content with automatic key rotation on quota errors
  /// and exponential backoff retry on transient 503/UNAVAILABLE errors.
  /// Throws [QuotaExhaustedException] if all keys are exhausted.
  /// Throws [ServerBusyException] if all retries on 503 fail.
  Future<GenerateContentResponse> generateContent(
      List<Content> content) async {
    final startIndex = _currentIndex;

    do {
      // Try current key with retries for transient errors
      for (var attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          final response =
              await _models[_currentIndex].generateContent(content);
          return response; // Success — stay on this key
        } catch (e) {
          if (_isQuotaError(e)) {
            _rotateToNext(startIndex);
            break; // Move to next key
          } else if (_isTransientError(e)) {
            if (attempt < _maxRetries - 1) {
              // Exponential backoff: 1s, 2s, 4s
              final delay = _baseDelay * (1 << attempt);
              await Future<void>.delayed(delay);
              continue; // Retry same key
            }
            // Last attempt failed — throw user-friendly error
            throw const ServerBusyException();
          } else {
            rethrow; // Non-transient, non-quota error — propagate immediately
          }
        }
      }
    } while (_currentIndex != startIndex); // Stop when we've tried all keys

    throw const QuotaExhaustedException();
  }

  bool _isQuotaError(Object error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('429') ||
        errorStr.contains('quota exceeded') ||
        errorStr.contains('too many requests');
  }

  bool _isTransientError(Object error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('503') ||
        errorStr.contains('unavailable') ||
        errorStr.contains('overloaded') ||
        errorStr.contains('model is overloaded');
  }

  void _rotateToNext(int startIndex) {
    _currentIndex = (_currentIndex + 1) % _models.length;
    if (_currentIndex == startIndex) {
      // All keys attempted — reset to first key for future requests
      _currentIndex = 0;
    }
  }
}
