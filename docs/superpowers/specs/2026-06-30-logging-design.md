# App-Wide Logging Design

**Date:** 2026-06-30
**Package:** `logger` (pub.dev)
**Architecture:** Singleton static class

---

## Overview

Add structured logging across the entire app using the `logger` package. A singleton `AppLogger` class provides `debug`, `info`, `warning`, and `error` methods. Debug mode shows all logs; release mode shows errors only.

## Setup

### 1. Add dependency

Add `logger: ^2.5.0` to `pubspec.yaml` under `dependencies`.

### 2. Create `lib/core/utils/app_logger.dart`

Singleton static class wrapping the `logger` package:

```dart
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: kDebugMode ? 2 : 0,
      errorMethodCount: kDebugMode ? 5 : 0,
      lineLength: 80,
      colors: kDebugMode,
      printEmojis: true,
      printTime: kDebugMode,
    ),
    level: kDebugMode ? Level.debug : Level.error,
    output: ConsoleOutput(),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

## Files to Modify

### Repositories (add logging to existing catch blocks)

Each repository already has try/catch. Add `AppLogger.error(...)` in every catch block before returning `Left(Failure(...))`.

| File | Methods | Log calls |
|------|---------|-----------|
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | `signIn`, `signUp`, `signOut` | 6 catch blocks |
| `lib/features/profile/data/repositories/profile_repository_impl.dart` | `getProfile`, `saveProfile` | 4 catch blocks |
| `lib/features/food_log/data/repositories/food_log_repository_impl.dart` | `logFood`, `getDailyLogs`, `deleteFoodLog` | 6 catch blocks |
| `lib/features/analytics/data/repositories/analytics_repository_impl.dart` | `getDailyStats`, `getWeeklyStats`, `getMonthlyStats` | 6 catch blocks |

**Pattern:**
```dart
} catch (e, stackTrace) {
  AppLogger.error('Failed to signIn', e, stackTrace);
  return Left(AuthFailure('Authentication failed. Please try again.'));
}
```

### Gemini Datasources (wrap in try/catch, log, rethrow)

These currently have no error handling. Wrap API calls in try/catch, log, then rethrow so existing usecase catch blocks still work.

| File | Methods |
|------|---------|
| `lib/features/food_log/data/datasources/gemini_datasource.dart` | `analyzeFood` |
| `lib/features/food_log/data/datasources/gemini_vision_datasource.dart` | `analyzeFoodImage` |
| `lib/features/profile/data/datasources/gemini_calorie_datasource.dart` | `getCalorieRecommendation` |

**Pattern:**
```dart
try {
  final response = await _model.generateContent(...);
  // ... parse ...
} catch (e, stackTrace) {
  AppLogger.error('Gemini API error: analyzeFood', e, stackTrace);
  rethrow;
}
```

### Supabase Datasources (wrap in try/catch, log, rethrow)

Same pattern — wrap Supabase calls, log errors, rethrow.

| File | Methods |
|------|---------|
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | `signIn`, `signUp`, `signOut` |
| `lib/features/profile/data/datasources/profile_remote_datasource.dart` | `getProfile`, `saveProfile` |
| `lib/features/food_log/data/datasources/food_log_remote_datasource.dart` | `logFood`, `getDailyLogs`, `deleteFoodLog` |
| `lib/features/analytics/data/datasources/analytics_remote_datasource.dart` | `getLogsByDateRange` |

**Pattern:**
```dart
try {
  final response = await client.from('table')...
} catch (e, stackTrace) {
  AppLogger.error('Supabase error: getProfile', e, stackTrace);
  rethrow;
}
```

### Usecases (add logging to existing catch blocks)

| File | Methods |
|------|---------|
| `lib/features/food_log/domain/usecases/analyze_food.dart` | `call` |
| `lib/features/food_log/domain/usecases/analyze_food_image.dart` | `call` |
| `lib/features/profile/domain/usecases/get_calorie_recommendation.dart` | `call` |

**Pattern:**
```dart
} catch (e, stackTrace) {
  AppLogger.error('Failed to analyze food', e, stackTrace);
  return Left(ServerFailure('Unable to analyze food. Please try again.'));
}
```

### main.dart

Log Supabase initialization:

```dart
try {
  await Supabase.initialize(...);
  AppLogger.info('Supabase initialized successfully');
} catch (e, stackTrace) {
  AppLogger.error('Failed to initialize Supabase', e, stackTrace);
  rethrow;
}
```

## Behavior

- **No logic changes.** All error handling, Failure types, user-facing messages, and exception propagation remain identical.
- **Logging is additive.** It observes but does not alter control flow.
- **Debug mode (`kDebugMode`):** All log levels, full stack traces, colors, emojis, timestamps.
- **Release mode:** Errors only, no stack traces, no colors.
- **No `print()` calls** exist in the current codebase (verified).

## Naming Convention

Log messages follow this pattern:
- **Repositories:** `'Failed to <action>'` (e.g., `'Failed to signIn'`)
- **Datasources:** `'<Service> error: <method>'` (e.g., `'Supabase error: getProfile'`, `'Gemini API error: analyzeFood'`)
- **main.dart:** `'Supabase initialized successfully'` / `'Failed to initialize Supabase'`
