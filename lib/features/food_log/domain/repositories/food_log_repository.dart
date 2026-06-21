import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/features/food_log/domain/entities/food_log.dart';

abstract class FoodLogRepository {
  Future<Either<Failure, FoodLog>> logFood(FoodLog foodLog);
  Future<Either<Failure, List<FoodLog>>> getDailyLogs(DateTime date);
  Future<Either<Failure, void>> deleteFoodLog(String id);
}
