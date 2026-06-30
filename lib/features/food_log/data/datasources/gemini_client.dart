import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bite_balance/core/errors/failures.dart';

/// Client that wraps multiple GenerativeModel instances and rotates
/// through them on quota errors (429 / "Quota exceeded").
class GeminiClient {
  final List<GenerativeModel> _models;
  int _currentIndex = 0;

  /// Creates a GeminiClient with a list of API keys.
  /// At least one non-empty key is required.
  GeminiClient(List<String> apiKeys)
      : _models = apiKeys
            .where((key) => key.isNotEmpty)
            .map((key) => GenerativeModel(
                  model: 'gemini-2.5-flash-lite',
                  apiKey: key,
                ))
            .toList() {
    if (_models.isEmpty) {
      throw ArgumentError('At least one API key is required');
    }
  }

  /// Generates content with automatic key rotation on quota errors.
  /// Throws [QuotaExhaustedException] if all keys are exhausted.
  Future<GenerateContentResponse> generateContent(
      List<Content> content) async {
    final startIndex = _currentIndex;

    do {
      try {
        final response =
            await _models[_currentIndex].generateContent(content);
        return response; // Success — stay on this key
      } catch (e) {
        if (_isQuotaError(e)) {
          _rotateToNext(startIndex);
          continue; // Try next key
        }
        rethrow; // Non-quota error — propagate immediately
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

  void _rotateToNext(int startIndex) {
    _currentIndex = (_currentIndex + 1) % _models.length;
    if (_currentIndex == startIndex) {
      // All keys attempted — reset to first key for future requests
      _currentIndex = 0;
    }
  }
}
