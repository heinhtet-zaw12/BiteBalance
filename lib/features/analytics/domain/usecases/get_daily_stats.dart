import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/analytics/domain/entities/analytics_stats.dart';
import 'package:bite_balance/features/analytics/domain/repositories/analytics_repository.dart';

class GetDailyStats implements UseCase<DailyStats, GetDailyStatsParams> {
  final AnalyticsRepository repository;

  GetDailyStats(this.repository);

  @override
  Future<Either<Failure, DailyStats>> call(GetDailyStatsParams params) {
    return repository.getDailyStats(params.date);
  }
}

class GetDailyStatsParams {
  final DateTime date;

  const GetDailyStatsParams({required this.date});
}
