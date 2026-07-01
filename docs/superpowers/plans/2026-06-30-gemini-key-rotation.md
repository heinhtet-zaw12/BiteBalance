# Gemini API Key Rotation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement automatic API key rotation for Gemini food analysis, falling back through 3 keys on quota errors before showing a user-friendly message.

**Architecture:** New `GeminiClient` abstraction wraps multiple `GenerativeModel` instances (one per key). Data sources use this client instead of `GenerativeModel` directly. Sequential fallback rotation on quota errors (429 / "Quota exceeded"). `QuotaExhaustedException` thrown when all keys fail.

**Tech Stack:** Flutter, Dart, google_generative_ai ^0.4.6, flutter_riverpod, flutter_dotenv, fpdart

## Global Constraints

- Follow Clean Architecture (Presentation → Domain ← Data)
- Use `const` constructors everywhere possible
- All async states use `AsyncValue` from Riverpod
- No direct Supabase calls from UI layer
- No business logic inside Widget `build()` method
- Environment variables via `flutter_dotenv` — never hardcode keys
- Files: `snake_case.dart`, Classes: `PascalCase`, Variables/methods: `camelCase`

---

## File Structure

### Files to Create

| File | Responsibility |
|------|----------------|
| `lib/features/food_log/data/datasources/gemini_client.dart` | Key rotation logic, wraps multiple GenerativeModel instances |
| `test/features/food_log/data/datasources/gemini_client_test.dart` | Unit tests for GeminiClient rotation logic |

### Files to Modify

| File | Changes |
|------|---------|
| `lib/core/errors/failures.dart` | Add `QuotaExhaustedException` class |
| `lib/core/utils/error_handler.dart` | Handle `QuotaExhaustedException` in `message()` |
| `lib/features/food_log/data/datasources/gemini_datasource.dart` | Constructor takes `GeminiClient` instead of `String apiKey` |
| `lib/features/food_log/data/datasources/gemini_vision_datasource.dart` | Constructor takes `GeminiClient` instead of `String apiKey` |
| `lib/features/food_log/presentation/providers/food_log_provider.dart` | Add `geminiClientProvider`, update data source providers |
| `lib/features/food_log/domain/usecases/analyze_food.dart` | Catch `QuotaExhaustedException` specifically |
| `lib/features/food_log/domain/usecases/analyze_food_image.dart` | Catch `QuotaExhaustedException` specifically |
| `.env` | Replace `GEMINI_API_KEY` with `GEMINI_API_KEY_1`, `_2`, `_3` |
| `.env.example` | Update template with 3 key placeholders |

---

### Task 1: Add QuotaExhaustedException to failures.dart

**Files:**
- Modify: `lib/core/errors/failures.dart`

**Interfaces:**
- Produces: `QuotaExhaustedException` class used by GeminiClient, ErrorHandler, and UseCases

- [ ] **Step 1: Add QuotaExhaustedException class**

```dart
// Add to lib/core/errors/failures.dart after CacheFailure class

class QuotaExhaustedException implements Exception {
  final String message;
  const QuotaExhaustedException([
    this.message = 'AI analysis is temporarily unavailable. Please try again in a few minutes.',
  ]);

  @override
  String toString() => message;
}
```

- [ ] **Step 2: Verify no compilation errors**

Run: `flutter analyze lib/core/errors/failures.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/core/errors/failures.dart
git commit -m "feat: add QuotaExhaustedException for key rotation"
```

---

### Task 2: Update ErrorHandler to handle QuotaExhaustedException

**Files:**
- Modify: `lib/core/utils/error_handler.dart`

**Interfaces:**
- Consumes: `QuotaExhaustedException` from Task 1
- Produces: User-friendly message for quota exhaustion errors

- [ ] **Step 1: Add QuotaExhaustedException check to ErrorHandler.message()**

```dart
// Add at the top of ErrorHandler.message() method, before the "if (error is Failure)" check

// Quota exhaustion — already has user-friendly message
if (error is QuotaExhaustedException) {
  return error.message;
}
```

- [ ] **Step 2: Add import for QuotaExhaustedException**

```dart
// Add to imports in error_handler.dart
import 'package:bite_balance/core/errors/failures.dart';
```

- [ ] **Step 3: Verify no compilation errors**

Run: `flutter analyze lib/core/utils/error_handler.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/core/utils/error_handler.dart
git commit -m "feat: handle QuotaExhaustedException in ErrorHandler"
```

---

### Task 3: Create GeminiClient with key rotation logic

**Files:**
- Create: `lib/features/food_log/data/datasources/gemini_client.dart`

**Interfaces:**
- Consumes: `google_generative_ai` package's `GenerativeModel`, `Content`, `GenerateContentResponse`
- Consumes: `QuotaExhaustedException` from Task 1
- Produces: `GeminiClient.generateContent(List<Content>)` → `Future<GenerateContentResponse>`
- Produces: `GeminiClient(List<String> apiKeys)` constructor

- [ ] **Step 1: Create gemini_client.dart with QuotaExhaustedException re-export**

```dart
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
```

- [ ] **Step 2: Verify no compilation errors**

Run: `flutter analyze lib/features/food_log/data/datasources/gemini_client.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/food_log/data/datasources/gemini_client.dart
git commit -m "feat: create GeminiClient with key rotation logic"
```

---

### Task 4: Write unit tests for GeminiClient

**Files:**
- Create: `test/features/food_log/data/datasources/gemini_client_test.dart`

**Interfaces:**
- Tests: `GeminiClient` from Task 3
- Mocks: `GenerativeModel` (or test with real API if integration test)

- [ ] **Step 1: Create test file with rotation tests**

```dart
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
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `flutter test test/features/food_log/data/datasources/gemini_client_test.dart`
Expected: All tests pass

- [ ] **Step 3: Commit**

```bash
git add test/features/food_log/data/datasources/gemini_client_test.dart
git commit -m "test: add GeminiClient unit tests"
```

---

### Task 5: Update GeminiDataSource to use GeminiClient

**Files:**
- Modify: `lib/features/food_log/data/datasources/gemini_datasource.dart`

**Interfaces:**
- Consumes: `GeminiClient` from Task 3
- Produces: Same `GeminiDataSource` interface (no change to abstract class)

- [ ] **Step 1: Update imports**

```dart
// Replace import at top of file
import 'dart:convert';
import 'package:bite_balance/features/food_log/data/datasources/gemini_client.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
```

- [ ] **Step 2: Update GeminiDataSourceImpl constructor**

```dart
// Replace constructor in GeminiDataSourceImpl
class GeminiDataSourceImpl implements GeminiDataSource {
  final GeminiClient _client;

  GeminiDataSourceImpl(GeminiClient client) : _client = client;
```

- [ ] **Step 3: Update analyzeFood method to use _client**

```dart
// Replace _model.generateContent call in analyzeFood method
final response = await _client.generateContent([Content.text(prompt)]);
```

- [ ] **Step 4: Remove unused import**

```dart
// Remove this import (no longer needed)
// import 'package:google_generative_ai/google_generative_ai.dart';
```

Note: Keep `import 'package:google_generative_ai/google_generative_ai.dart';` if `Content` is still used in the method. Check the file.

- [ ] **Step 5: Verify no compilation errors**

Run: `flutter analyze lib/features/food_log/data/datasources/gemini_datasource.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add lib/features/food_log/data/datasources/gemini_datasource.dart
git commit -m "refactor: update GeminiDataSource to use GeminiClient"
```

---

### Task 6: Update GeminiVisionDataSource to use GeminiClient

**Files:**
- Modify: `lib/features/food_log/data/datasources/gemini_vision_datasource.dart`

**Interfaces:**
- Consumes: `GeminiClient` from Task 3
- Produces: Same `GeminiVisionDataSource` interface (no change to abstract class)

- [ ] **Step 1: Update imports**

```dart
// Replace imports at top of file
import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_client.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_datasource.dart';
```

- [ ] **Step 2: Update GeminiVisionDataSourceImpl constructor**

```dart
// Replace constructor in GeminiVisionDataSourceImpl
class GeminiVisionDataSourceImpl implements GeminiVisionDataSource {
  final GeminiClient _client;

  GeminiVisionDataSourceImpl(GeminiClient client) : _client = client;
```

- [ ] **Step 3: Update analyzeFoodImage method to use _client**

```dart
// Replace _model.generateContent call in analyzeFoodImage method
final response = await _client.generateContent([
  Content.multi([prompt, imagePart]),
]);
```

- [ ] **Step 4: Verify no compilation errors**

Run: `flutter analyze lib/features/food_log/data/datasources/gemini_vision_datasource.dart`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/features/food_log/data/datasources/gemini_vision_datasource.dart
git commit -m "refactor: update GeminiVisionDataSource to use GeminiClient"
```

---

### Task 7: Update food_log_provider.dart with geminiClientProvider

**Files:**
- Modify: `lib/features/food_log/presentation/providers/food_log_provider.dart`

**Interfaces:**
- Consumes: `GeminiClient` from Task 3
- Consumes: `dotenv` from flutter_dotenv
- Produces: `geminiClientProvider` (new)
- Produces: Updated `geminiDataSourceProvider` and `geminiVisionDataSourceProvider`

- [ ] **Step 1: Add import for GeminiClient**

```dart
// Add to imports
import 'package:bite_balance/features/food_log/data/datasources/gemini_client.dart';
```

- [ ] **Step 2: Add geminiClientProvider before data source providers**

```dart
// Add before geminiDataSourceProvider
final geminiClientProvider = Provider<GeminiClient>((ref) {
  return GeminiClient([
    dotenv.get('GEMINI_API_KEY_1'),
    dotenv.get('GEMINI_API_KEY_2'),
    dotenv.get('GEMINI_API_KEY_3'),
  ]);
});
```

- [ ] **Step 3: Update geminiDataSourceProvider to use geminiClientProvider**

```dart
// Replace geminiDataSourceProvider
final geminiDataSourceProvider = Provider<GeminiDataSource>((ref) {
  return GeminiDataSourceImpl(ref.read(geminiClientProvider));
});
```

- [ ] **Step 4: Update geminiVisionDataSourceProvider to use geminiClientProvider**

```dart
// Replace geminiVisionDataSourceProvider
final geminiVisionDataSourceProvider = Provider<GeminiVisionDataSource>((ref) {
  return GeminiVisionDataSourceImpl(ref.read(geminiClientProvider));
});
```

- [ ] **Step 5: Remove unused import**

```dart
// Remove this import if no longer needed
// import 'package:flutter_dotenv/flutter_dotenv.dart';
```

Note: Keep `flutter_dotenv` import if `dotenv` is still used elsewhere in the file.

- [ ] **Step 6: Verify no compilation errors**

Run: `flutter analyze lib/features/food_log/presentation/providers/food_log_provider.dart`
Expected: No issues found

- [ ] **Step 7: Commit**

```bash
git add lib/features/food_log/presentation/providers/food_log_provider.dart
git commit -m "feat: add geminiClientProvider with 3-key rotation"
```

---

### Task 8: Update use cases to catch QuotaExhaustedException

**Files:**
- Modify: `lib/features/food_log/domain/usecases/analyze_food.dart`
- Modify: `lib/features/food_log/domain/usecases/analyze_food_image.dart`

**Interfaces:**
- Consumes: `QuotaExhaustedException` from Task 1
- Produces: Same use case interface (no change to abstract class)

- [ ] **Step 1: Update analyze_food.dart imports**

```dart
// Add to imports in analyze_food.dart
import 'package:bite_balance/core/errors/failures.dart';
```

- [ ] **Step 2: Update analyze_food.dart call method**

```dart
// Replace the catch block in analyze_food.dart call method
@override
Future<Either<Failure, FoodAnalysisResult>> call(AnalyzeFoodParams params) async {
  try {
    final result = await geminiDataSource.analyzeFood(params.foodDescription);
    return Right(result);
  } on QuotaExhaustedException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e, stackTrace) {
    AppLogger.error('Failed to analyzeFood', e, stackTrace);
    return Left(ServerFailure('Unable to analyze food. Please try again.'));
  }
}
```

- [ ] **Step 3: Update analyze_food_image.dart imports**

```dart
// Add to imports in analyze_food_image.dart
import 'package:bite_balance/core/errors/failures.dart';
```

- [ ] **Step 4: Update analyze_food_image.dart call method**

```dart
// Replace the catch block in analyze_food_image.dart call method
@override
Future<Either<Failure, FoodAnalysisResult>> call(AnalyzeFoodImageParams params) async {
  try {
    final result = await visionDataSource.analyzeFoodImage(params.imageFile);
    return Right(result);
  } on QuotaExhaustedException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e, stackTrace) {
    AppLogger.error('Failed to analyzeFoodImage', e, stackTrace);
    return Left(ServerFailure('Unable to analyze food image. Please try again.'));
  }
}
```

- [ ] **Step 5: Verify no compilation errors**

Run: `flutter analyze lib/features/food_log/domain/usecases/analyze_food.dart lib/features/food_log/domain/usecases/analyze_food_image.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add lib/features/food_log/domain/usecases/analyze_food.dart lib/features/food_log/domain/usecases/analyze_food_image.dart
git commit -m "feat: catch QuotaExhaustedException in food analysis use cases"
```

---

### Task 9: Update .env files with 3 API keys

**Files:**
- Modify: `.env`
- Modify: `.env.example`

**Interfaces:**
- Produces: `GEMINI_API_KEY_1`, `GEMINI_API_KEY_2`, `GEMINI_API_KEY_3` environment variables

- [ ] **Step 1: Update .env.example**

```env
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
GEMINI_API_KEY_1=your-gemini-api-key-1
GEMINI_API_KEY_2=your-gemini-api-key-2
GEMINI_API_KEY_3=your-gemini-api-key-3
```

- [ ] **Step 2: Update .env (user must do this manually with their actual keys)**

Note: The user must update their `.env` file with their 3 actual API keys. The format should be:

```env
SUPABASE_URL=<existing-value>
SUPABASE_ANON_KEY=<existing-value>
GEMINI_API_KEY_1=<user's first key>
GEMINI_API_KEY_2=<user's second key>
GEMINI_API_KEY_3=<user's third key>
```

- [ ] **Step 3: Verify .env is in .gitignore**

Run: `grep -n "\.env" /Users/airm2/Desktop/bite_balance/.gitignore`
Expected: `.env` is listed

- [ ] **Step 4: Commit .env.example only (never commit .env)**

```bash
git add .env.example
git commit -m "chore: update .env.example with 3 Gemini API keys"
```

---

### Task 10: Final integration verification

**Files:**
- None (verification only)

**Interfaces:**
- Verifies: All changes integrate correctly

- [ ] **Step 1: Run full project analysis**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 3: Verify app builds**

Run: `flutter build apk --debug` (or `flutter build ios --debug` for iOS)
Expected: Build succeeds

- [ ] **Step 4: Manual test with real keys**

1. Add 3 valid Gemini API keys to `.env`
2. Run the app
3. Test food analysis with text input
4. Test food analysis with image input
5. Verify rotation works by using a key with exhausted quota
6. Verify user-friendly message when all keys exhausted

- [ ] **Step 5: Final commit if any fixes needed**

```bash
git add -A
git commit -m "fix: integration fixes for Gemini key rotation"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Add QuotaExhaustedException | failures.dart |
| 2 | Update ErrorHandler | error_handler.dart |
| 3 | Create GeminiClient | gemini_client.dart |
| 4 | Write GeminiClient tests | gemini_client_test.dart |
| 5 | Update GeminiDataSource | gemini_datasource.dart |
| 6 | Update GeminiVisionDataSource | gemini_vision_datasource.dart |
| 7 | Update providers | food_log_provider.dart |
| 8 | Update use cases | analyze_food.dart, analyze_food_image.dart |
| 9 | Update .env files | .env, .env.example |
| 10 | Final verification | (none) |

**Total tasks:** 10
**Estimated time:** 45-60 minutes
