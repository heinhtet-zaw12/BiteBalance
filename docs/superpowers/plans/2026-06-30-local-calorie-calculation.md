# Local Calorie Calculation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Gemini API calorie recommendation with a local Mifflin-St Jeor calculation, eliminating API quota issues.

**Architecture:** The `GetCalorieRecommendation` use case is rewritten to compute BMR/TDEE locally using weight, height, and goal. The `GeminiCalorieDataSource` file is deleted. The provider is simplified to remove the data source dependency.

**Tech Stack:** Dart (pure math, no external packages)

## Global Constraints

- Do NOT touch food analysis features (gemini_datasource.dart, gemini_vision_datasource.dart)
- Do NOT change any UI files (home_page.dart, analytics_page.dart)
- Keep the `CalorieRecommendation` entity unchanged (same fields: dailyCalorieTarget, healthyRatio, reasoning)
- Keep the `CalorieRecommendationNotifier` and `calorieRecommendationProvider` interface unchanged
- Formula: BMR = (10 × weightKg) + (6.25 × heightCm) - 5; TDEE = BMR × 1.55
- Goal adjustments: lose = -500 (healthyRatio 0.85), maintain = +0 (0.80), gain = +400 (0.75)
- Minimum calorie target: 1200

---

### Task 1: Rewrite use case with local calculation and delete Gemini data source

**Files:**
- Delete: `lib/features/profile/data/datasources/gemini_calorie_datasource.dart`
- Rewrite: `lib/features/profile/domain/usecases/get_calorie_recommendation.dart`
- Modify: `lib/features/profile/presentation/providers/profile_provider.dart`

**Interfaces:**
- Produces: `GetCalorieRecommendation()` — no constructor args, `call(GetCalorieRecommendationParams)` → `Either<Failure, CalorieRecommendation>`
- Produces: `GetCalorieRecommendationParams(weightKg: double, heightCm: double, goal: String)`
- Consumes: `CalorieRecommendation(dailyCalorieTarget: double, healthyRatio: double, reasoning: String)` — unchanged entity

- [ ] **Step 1: Delete GeminiCalorieDataSource file**

```bash
rm lib/features/profile/data/datasources/gemini_calorie_datasource.dart
```

- [ ] **Step 2: Rewrite GetCalorieRecommendation use case**

Replace the entire contents of `lib/features/profile/domain/usecases/get_calorie_recommendation.dart`:

```dart
import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/profile/domain/entities/calorie_recommendation.dart';

class GetCalorieRecommendation
    implements UseCase<CalorieRecommendation, GetCalorieRecommendationParams> {

  const GetCalorieRecommendation();

  @override
  Future<Either<Failure, CalorieRecommendation>> call(
    GetCalorieRecommendationParams params,
  ) async {
    final bmr = (10 * params.weightKg) + (6.25 * params.heightCm) - 5;
    final tdee = bmr * 1.55; // moderate activity

    double calorieAdjustment;
    double healthyRatio;
    String goalLabel;

    switch (params.goal) {
      case 'lose':
        calorieAdjustment = -500;
        healthyRatio = 0.85;
        goalLabel = 'weight loss';
      case 'gain':
        calorieAdjustment = 400;
        healthyRatio = 0.75;
        goalLabel = 'weight gain';
      case 'maintain':
      default:
        calorieAdjustment = 0;
        healthyRatio = 0.80;
        goalLabel = 'maintenance';
    }

    final target = (tdee + calorieAdjustment).clamp(1200.0, double.infinity);

    return Right(CalorieRecommendation(
      dailyCalorieTarget: target,
      healthyRatio: healthyRatio,
      reasoning: 'Based on Mifflin-St Jeor: BMR ${bmr.round()} kcal, '
          'TDEE ${tdee.round()} kcal (moderate activity). '
          'Adjusted for $goalLabel: ${target.round()} kcal/day.',
    ));
  }
}

class GetCalorieRecommendationParams {
  final double weightKg;
  final double heightCm;
  final String goal;

  const GetCalorieRecommendationParams({
    required this.weightKg,
    required this.heightCm,
    required this.goal,
  });
}
```

- [ ] **Step 3: Update profile_provider.dart**

Replace the Gemini data source provider and use case provider in `lib/features/profile/presentation/providers/profile_provider.dart`.

Remove these lines (the Gemini data source provider):
```dart
// Gemini calorie data source provider
final geminiCalorieDataSourceProvider = Provider<GeminiCalorieDataSource>((ref) {
  return GeminiCalorieDataSourceImpl(dotenv.get('GEMINI_API_KEY'));
});
```

Replace the use case provider:
```dart
// Get calorie recommendation use case provider
final getCalorieRecommendationProvider = Provider<GetCalorieRecommendation>((ref) {
  return GetCalorieRecommendation(ref.read(geminiCalorieDataSourceProvider));
});
```

With:
```dart
// Get calorie recommendation use case provider
final getCalorieRecommendationProvider = Provider<GetCalorieRecommendation>((ref) {
  return const GetCalorieRecommendation();
});
```

Remove the unused import:
```dart
import 'package:bite_balance/features/profile/data/datasources/gemini_calorie_datasource.dart';
```

Check if `flutter_dotenv` import is still needed. It is NOT used elsewhere in this file after removing the Gemini provider, so also remove:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
```

- [ ] **Step 4: Verify no analysis errors**

```bash
flutter analyze
```

Expected: No issues found. (Other files that imported gemini_calorie_datasource.dart — `get_calorie_recommendation.dart` — was already rewritten in Step 2.)

- [ ] **Step 5: Verify Gemini food analysis is untouched**

```bash
# Confirm these files still exist and import google_generative_ai
grep -l "google_generative_ai" lib/features/food_log/data/datasources/gemini_datasource.dart lib/features/food_log/data/datasources/gemini_vision_datasource.dart
```

Expected: Both files listed — food analysis still uses Gemini.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: replace Gemini calorie API with local Mifflin-St Jeor calculation"
```
