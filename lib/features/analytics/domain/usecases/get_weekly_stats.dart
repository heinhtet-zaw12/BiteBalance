import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/analytics/domain/entities/analytics_stats.dart';
import 'package:bite_balance/features/analytics/domain/repositories/analytics_repository.dart';

class GetWeeklyStats implements UseCase<WeeklyStats, GetWeeklyStatsParams> {
  final AnalyticsRepository repository;

  GetWeeklyStats(this.repository);

  @override
  Future<Either<Failure, WeeklyStats>> call(GetWeeklyStatsParams params) {
    return repository.getWeeklyStats(params.weekStart);
  }
}

class GetWeeklyStatsParams {
  final DateTime weekStart;

  const GetWeeklyStatsParams({required this.weekStart});
}
