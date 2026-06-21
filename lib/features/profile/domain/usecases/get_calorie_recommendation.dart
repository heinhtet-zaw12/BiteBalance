import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/profile/domain/entities/calorie_recommendation.dart';
import 'package:bite_balance/features/profile/data/datasources/gemini_calorie_datasource.dart';

class GetCalorieRecommendation
    implements UseCase<CalorieRecommendation, GetCalorieRecommendationParams> {
  final GeminiCalorieDataSource dataSource;

  GetCalorieRecommendation(this.dataSource);

  @override
  Future<Either<Failure, CalorieRecommendation>> call(
    GetCalorieRecommendationParams params,
  ) async {
    try {
      final result = await dataSource.getCalorieRecommendation(
        weightKg: params.weightKg,
        heightCm: params.heightCm,
        goal: params.goal,
      );

      return Right(CalorieRecommendation(
        dailyCalorieTarget: result.dailyCalorieTarget,
        healthyRatio: result.healthyRatio,
        reasoning: result.reasoning,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
