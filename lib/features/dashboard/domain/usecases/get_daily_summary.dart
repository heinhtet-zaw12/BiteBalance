import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/dashboard/domain/entities/daily_summary.dart';
import 'package:bite_balance/features/food_log/domain/repositories/food_log_repository.dart';

class GetDailySummary implements UseCase<DailySummary, GetDailySummaryParams> {
  final FoodLogRepository repository;

  const GetDailySummary(this.repository);

  @override
  Future<Either<Failure, DailySummary>> call(GetDailySummaryParams params) async {
    final result = await repository.getDailyLogs(params.date);

    return result.fold(
      (failure) => Left(failure),
      (logs) => Right(DailySummary(
        date: params.date,
        foodLogs: logs,
      )),
    );
  }
}

class GetDailySummaryParams {
  final DateTime date;

  const GetDailySummaryParams({required this.date});
}
