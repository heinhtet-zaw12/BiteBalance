import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/features/analytics/domain/entities/analytics_stats.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, DailyStats>> getDailyStats(DateTime date);
  Future<Either<Failure, WeeklyStats>> getWeeklyStats(DateTime weekStart);
  Future<Either<Failure, MonthlyStats>> getMonthlyStats(int year, int month);
}
