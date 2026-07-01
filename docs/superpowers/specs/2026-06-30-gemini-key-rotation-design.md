# Gemini API Key Rotation Design

**Date:** 2026-06-30  
**Status:** Approved  
**Scope:** Food analysis feature only (not calorie calculation)

---

## Problem

The app uses a single Gemini API key for food analysis. When the quota is exceeded, the user sees an error and must wait. With 3 available keys, we can automatically rotate to the next key when one is exhausted.

## Requirements

1. Load 3 API keys from `.env` (`GEMINI_API_KEY_1`, `GEMINI_API_KEY_2`, `GEMINI_API_KEY_3`)
2. On quota exceeded error (HTTP 429 or "Quota exceeded for metric"), automatically try the next key
3. If all 3 keys are exhausted, show user-friendly message: "AI analysis is temporarily unavailable. Please try again in a few minutes."
4. Rotation is fully transparent to the user
5. Only apply to food analysis feature — do not change calorie calculation

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                        │
│  food_log_provider.dart → uses AnalyzeFood / AnalyzeFoodImage   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                          Domain Layer                            │
│  AnalyzeFood → calls GeminiDataSource.analyzeFood()             │
│  AnalyzeFoodImage → calls GeminiVisionDataSource.analyzeFoodImage() │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                          Data Layer                              │
│  GeminiDataSourceImpl → uses GeminiClient                       │
│  GeminiVisionDataSourceImpl → uses GeminiClient                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      NEW: GeminiClient                           │
│  - Holds List<GenerativeModel> (one per key)                    │
│  - Rotates on quota errors (429 / "Quota exceeded")             │
│  - Throws QuotaExhaustedException if all keys fail              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    .env (3 API keys)                             │
│  GEMINI_API_KEY_1=...                                           │
│  GEMINI_API_KEY_2=...                                           │
│  GEMINI_API_KEY_3=...                                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## GeminiClient Class

**File:** `lib/features/food_log/data/datasources/gemini_client.dart`

```dart
class QuotaExhaustedException implements Exception {
  final String message;
  const QuotaExhaustedException([
    this.message = 'AI analysis is temporarily unavailable. Please try again in a few minutes.',
  ]);
  
  @override
  String toString() => message;
}

class GeminiClient {
  final List<GenerativeModel> _models;
  int _currentIndex = 0;
  
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
  Future<GenerateContentResponse> generateContent(List<Content> content) async {
    final startIndex = _currentIndex;
    
    do {
      try {
        final response = await _models[_currentIndex].generateContent(content);
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

### Design Decisions

- **Round-robin rotation**: Starts at key 0, rotates on failure, stops when all tried
- **Sticky success**: If a key works, stay on it for next request (avoids unnecessary rotation)
- **Stateless after exhaustion**: Once all keys fail, reset to key 0 for future requests (keys may recover)
- **Minimal model changes**: Data sources just call `client.generateContent(...)` instead of `model.generateContent(...)`

---

## Data Source Changes

### gemini_datasource.dart

```dart
// BEFORE
class GeminiDataSourceImpl implements GeminiDataSource {
  final GenerativeModel _model;
  
  GeminiDataSourceImpl(String apiKey)
      : _model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);

// AFTER
class GeminiDataSourceImpl implements GeminiDataSource {
  final GeminiClient _client;
  
  GeminiDataSourceImpl(GeminiClient client) : _client = client;
```

### gemini_vision_datasource.dart

Same pattern — constructor takes `GeminiClient` instead of `String apiKey`.

---

## Provider Changes

**File:** `lib/features/food_log/presentation/providers/food_log_provider.dart`

```dart
// NEW: Shared GeminiClient provider
final geminiClientProvider = Provider<GeminiClient>((ref) {
  return GeminiClient([
    dotenv.get('GEMINI_API_KEY_1'),
    dotenv.get('GEMINI_API_KEY_2'),
    dotenv.get('GEMINI_API_KEY_3'),
  ]);
});

// UPDATED: Use shared client
final geminiDataSourceProvider = Provider<GeminiDataSource>((ref) {
  return GeminiDataSourceImpl(ref.read(geminiClientProvider));
});

final geminiVisionDataSourceProvider = Provider<GeminiVisionDataSource>((ref) {
  return GeminiVisionDataSourceImpl(ref.read(geminiClientProvider));
});
```

---

## Error Handling

### New Exception

```dart
// Add to lib/core/errors/failures.dart
class QuotaExhaustedException implements Exception {
  final String message;
  const QuotaExhaustedException([
    this.message = 'AI analysis is temporarily unavailable. Please try again in a few minutes.',
  ]);
  
  @override
  String toString() => message;
}
```

### ErrorHandler Update

```dart
// Add to ErrorHandler.message() at the top
if (error is QuotaExhaustedException) {
  return error.message; // Already user-friendly
}
```

### Use Case Update

```dart
// In analyze_food.dart and analyze_food_image.dart
@override
Future<Either<Failure, FoodAnalysisResult>> call(params) async {
  try {
    // ... existing logic
  } on QuotaExhaustedException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e, stackTrace) {
    AppLogger.error('Failed to analyzeFood', e, stackTrace);
    return Left(ServerFailure('Unable to analyze food. Please try again.'));
  }
}
```

### Error Flow

```
All 3 keys exhausted
        ↓
GeminiClient throws QuotaExhaustedException
        ↓
Use case catches → returns Left(ServerFailure("AI analysis is temporarily unavailable..."))
        ↓
Provider shows error via ErrorHandler.message()
        ↓
User sees: "AI analysis is temporarily unavailable. Please try again in a few minutes."
```

---

## Environment Variables

### .env

```env
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
GEMINI_API_KEY_1=your-first-key
GEMINI_API_KEY_2=your-second-key
GEMINI_API_KEY_3=your-third-key
```

### .env.example

```env
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
GEMINI_API_KEY_1=your-gemini-api-key-1
GEMINI_API_KEY_2=your-gemini-api-key-2
GEMINI_API_KEY_3=your-gemini-api-key-3
```

---

## Scope

### Files to Modify

| File | Change |
|------|--------|
| `lib/features/food_log/data/datasources/gemini_client.dart` | **NEW** — rotation logic |
| `lib/features/food_log/data/datasources/gemini_datasource.dart` | Constructor takes `GeminiClient` |
| `lib/features/food_log/data/datasources/gemini_vision_datasource.dart` | Constructor takes `GeminiClient` |
| `lib/features/food_log/presentation/providers/food_log_provider.dart` | New `geminiClientProvider`, update data source providers |
| `lib/core/errors/failures.dart` | Add `QuotaExhaustedException` |
| `lib/core/utils/error_handler.dart` | Handle `QuotaExhaustedException` |
| `.env` | Switch to 3 keys |
| `.env.example` | Update template |

### Files NOT Modified

- ✅ Calorie calculation (not Gemini-based)
- ✅ Domain entities
- ✅ Use case interfaces (only internal catch block changes)
- ✅ UI pages
- ✅ Repository layer
- ✅ Food log remote data source (Supabase)

---

## Testing Strategy

1. **Unit test GeminiClient**: Mock `GenerativeModel`, verify rotation on quota errors
2. **Unit test data sources**: Verify they use `GeminiClient` correctly
3. **Integration test**: Verify end-to-end flow with mock keys
4. **Manual test**: Verify user-friendly error message when all keys exhausted

---

## Future Considerations

- **Cooldown logic**: If keys recover after time, could add exponential backoff
- **Key health tracking**: Could persist key status across app restarts
- **Dynamic key loading**: Could fetch keys from remote config instead of .env
