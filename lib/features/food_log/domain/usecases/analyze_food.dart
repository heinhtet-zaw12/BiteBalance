import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_datasource.dart';

class AnalyzeFood implements UseCase<FoodAnalysisResult, AnalyzeFoodParams> {
  final GeminiDataSource geminiDataSource;

  const AnalyzeFood(this.geminiDataSource);

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
}

class AnalyzeFoodParams {
  final String foodDescription;

  const AnalyzeFoodParams({required this.foodDescription});
}
