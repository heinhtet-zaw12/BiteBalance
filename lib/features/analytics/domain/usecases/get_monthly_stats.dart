import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/analytics/domain/entities/analytics_stats.dart';
import 'package:bite_balance/features/analytics/domain/repositories/analytics_repository.dart';

class GetMonthlyStats implements UseCase<MonthlyStats, GetMonthlyStatsParams> {
  final AnalyticsRepository repository;

  GetMonthlyStats(this.repository);

  @override
  Future<Either<Failure, MonthlyStats>> call(GetMonthlyStatsParams params) {
    return repository.getMonthlyStats(params.year, params.month);
  }
}

class GetMonthlyStatsParams {
  final int year;
  final int month;

  const GetMonthlyStatsParams({required this.year, required this.month});
}
