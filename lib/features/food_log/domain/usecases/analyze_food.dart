import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
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
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class AnalyzeFoodParams {
  final String foodDescription;

  const AnalyzeFoodParams({required this.foodDescription});
}
