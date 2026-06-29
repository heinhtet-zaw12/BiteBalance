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
