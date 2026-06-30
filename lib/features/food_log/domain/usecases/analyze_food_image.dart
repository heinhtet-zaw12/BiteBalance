import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_datasource.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_vision_datasource.dart';

class AnalyzeFoodImage implements UseCase<FoodAnalysisResult, AnalyzeFoodImageParams> {
  final GeminiVisionDataSource visionDataSource;

  const AnalyzeFoodImage(this.visionDataSource);

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
}

class AnalyzeFoodImageParams {
  final File imageFile;

  const AnalyzeFoodImageParams({required this.imageFile});
}
