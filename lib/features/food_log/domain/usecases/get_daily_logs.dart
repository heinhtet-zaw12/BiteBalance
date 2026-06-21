import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/food_log/domain/entities/food_log.dart';
import 'package:bite_balance/features/food_log/domain/repositories/food_log_repository.dart';

class GetDailyLogs implements UseCase<List<FoodLog>, GetDailyLogsParams> {
  final FoodLogRepository repository;

  const GetDailyLogs(this.repository);

  @override
  Future<Either<Failure, List<FoodLog>>> call(GetDailyLogsParams params) {
    return repository.getDailyLogs(params.userId, params.date);
  }
}

class GetDailyLogsParams {
  final String userId;
  final DateTime date;

  const GetDailyLogsParams({required this.userId, required this.date});
}
