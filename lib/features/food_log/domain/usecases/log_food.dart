import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/food_log/domain/entities/food_log.dart';
import 'package:bite_balance/features/food_log/domain/repositories/food_log_repository.dart';

class LogFood implements UseCase<FoodLog, LogFoodParams> {
  final FoodLogRepository repository;

  const LogFood(this.repository);

  @override
  Future<Either<Failure, FoodLog>> call(LogFoodParams params) {
    return repository.logFood(params.foodLog);
  }
}

class LogFoodParams {
  final FoodLog foodLog;

  const LogFoodParams({required this.foodLog});
}
