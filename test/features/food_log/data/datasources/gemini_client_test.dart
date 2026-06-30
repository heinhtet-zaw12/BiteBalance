import 'package:flutter_test/flutter_test.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_client.dart';

void main() {
  group('GeminiClient', () {
    test('throws ArgumentError when no keys provided', () {
      expect(
        () => GeminiClient([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when all keys are empty', () {
      expect(
        () => GeminiClient(['', '', '']),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('creates instance with valid keys', () {
      expect(
        () => GeminiClient(['key1', 'key2', 'key3']),
        returnsNormally,
      );
    });

    test('filters out empty keys', () {
      expect(
        () => GeminiClient(['key1', '', 'key3']),
        returnsNormally,
      );
    });
  });
}
