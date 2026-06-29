# Local Calorie Calculation Design

**Date:** 2026-06-30

## Overview

Replace the Gemini API call for calorie recommendation with a local calculation using the Mifflin-St Jeor equation. This eliminates API quota issues and makes calorie recommendations instant.

## Problem

The current `GeminiCalorieDataSource` calls the Gemini API every time a calorie recommendation is needed, hitting quota limits. Calorie calculation is a deterministic math problem that doesn't need an AI API.

## Solution

Replace the Gemini data source with a local calculation function using standard nutrition science.

### Formula

Since the Profile entity has no age or gender fields, we use a simplified Mifflin-St Jeor equation:

```
BMR = (10 × weightKg) + (6.25 × heightCm) - 5
TDEE = BMR × 1.55  (moderate activity level)
```

Goal adjustments:
- **lose:** target = TDEE - 500, healthyRatio = 0.85
- **maintain:** target = TDEE, healthyRatio = 0.80
- **gain:** target = TDEE + 400, healthyRatio = 0.75

Minimum target: 1200 calories (safety floor).

Reasoning: Auto-generated string explaining the calculation.

### Files to Change

| Action | File | Change |
|--------|------|--------|
| Delete | `lib/features/profile/data/datasources/gemini_calorie_datasource.dart` | Remove entire file |
| Rewrite | `lib/features/profile/domain/usecases/get_calorie_recommendation.dart` | Replace Gemini data source with local calculation. No external dependency. |
| Update | `lib/features/profile/presentation/providers/profile_provider.dart` | Remove `geminiCalorieDataSourceProvider`, simplify `getCalorieRecommendationProvider` |

### What Stays Unchanged

- `CalorieRecommendation` entity (`lib/features/profile/domain/entities/calorie_recommendation.dart`) — same fields
- `CalorieRecommendationNotifier` — same interface, same `loadRecommendation` method
- `calorieRecommendationProvider` — same provider, same consumers
- `home_page.dart` — no changes
- `analytics_page.dart` — no changes
- All Gemini food analysis features (`gemini_datasource.dart`, `gemini_vision_datasource.dart`) — untouched

### Use Case Interface

The `GetCalorieRecommendation` use case keeps its existing interface:
- `call(GetCalorieRecommendationParams)` → `Either<Failure, CalorieRecommendation>`
- Params: `weightKg`, `heightCm`, `goal`
- Returns: `CalorieRecommendation(dailyCalorieTarget, healthyRatio, reasoning)`

Internally it becomes synchronous (no data source call), wrapped in `Future.value` to maintain the `UseCase` interface.

### Provider Changes

In `profile_provider.dart`:
- Remove: `geminiCalorieDataSourceProvider` (line 108-110)
- Remove: import of `gemini_calorie_datasource.dart`
- Remove: import of `flutter_dotenv` (if no longer needed)
- Update: `getCalorieRecommendationProvider` to create `GetCalorieRecommendation()` with no constructor args
