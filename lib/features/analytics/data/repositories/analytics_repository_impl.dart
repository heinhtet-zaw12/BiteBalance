import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:bite_balance/features/analytics/domain/entities/analytics_stats.dart';
import 'package:bite_balance/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:bite_balance/features/auth/domain/repositories/auth_repository.dart';
import 'package:bite_balance/features/food_log/data/models/food_log_model.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  AnalyticsRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, DailyStats>> getDailyStats(DateTime date) async {
    try {
      final userId = authRepository.currentUser?.id;
      if (userId == null) {
        return Left(ServerFailure('User not authenticated'));
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final logs = await remoteDataSource.getLogsByDateRange(
        userId,
        startOfDay,
        endOfDay,
      );

      return Right(DailyStats(
        date: date,
        totalCalories: logs.totalCalories,
        healthyCalories: logs.healthyCalories,
        junkCalories: logs.junkCalories,
        totalItems: logs.length,
        topJunkFoods: logs.getTopJunkFoods(),
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeeklyStats>> getWeeklyStats(
    DateTime weekStart,
  ) async {
    try {
      final userId = authRepository.currentUser?.id;
      if (userId == null) {
        return Left(ServerFailure('User not authenticated'));
      }

      // Ensure weekStart is the start of the week (Monday)
      final startOfWeek = weekStart.subtract(
        Duration(days: weekStart.weekday - 1),
      );
      final startOfDay = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      final endOfWeek = startOfDay.add(const Duration(days: 7));

      final logs = await remoteDataSource.getLogsByDateRange(
        userId,
        startOfDay,
        endOfWeek,
      );

      // Group logs by day
      final Map<String, List<FoodLogModel>> logsByDay = {};
      for (final log in logs) {
        final dateKey =
            '${log.createdAt.year}-${log.createdAt.month}-${log.createdAt.day}';
        logsByDay[dateKey] = [...(logsByDay[dateKey] ?? []), log];
      }

      // Create daily breakdown
      final List<DailyStats> dailyBreakdown = [];
      for (int i = 0; i < 7; i++) {
        final day = startOfDay.add(Duration(days: i));
        final dateKey = '${day.year}-${day.month}-${day.day}';
        final dayLogs = logsByDay[dateKey] ?? [];

        double dayTotal = 0;
        double dayHealthy = 0;
        double dayJunk = 0;
        for (final log in dayLogs) {
          dayTotal += log.calories;
          if (log.isJunk) {
            dayJunk += log.calories;
          } else {
            dayHealthy += log.calories;
          }
        }

        dailyBreakdown.add(DailyStats(
          date: day,
          totalCalories: dayTotal,
          healthyCalories: dayHealthy,
          junkCalories: dayJunk,
          totalItems: dayLogs.length,
          topJunkFoods: [],
        ));
      }

      return Right(WeeklyStats(
        startDate: startOfDay,
        endDate: endOfWeek,
        totalCalories: logs.totalCalories,
        averageDailyCalories: logs.totalCalories / 7,
        healthyCalories: logs.healthyCalories,
        junkCalories: logs.junkCalories,
        dailyBreakdown: dailyBreakdown,
        topJunkFoods: logs.getTopJunkFoods(),
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MonthlyStats>> getMonthlyStats(
    int year,
    int month,
  ) async {
    try {
      final userId = authRepository.currentUser?.id;
      if (userId == null) {
        return Left(ServerFailure('User not authenticated'));
      }

      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 1);
      final daysInMonth = endOfMonth.difference(startOfMonth).inDays;

      final logs = await remoteDataSource.getLogsByDateRange(
        userId,
        startOfMonth,
        endOfMonth,
      );

      // Group logs by day
      final Map<String, List<FoodLogModel>> logsByDay = {};
      for (final log in logs) {
        final dateKey =
            '${log.createdAt.year}-${log.createdAt.month}-${log.createdAt.day}';
        logsByDay[dateKey] = [...(logsByDay[dateKey] ?? []), log];
      }

      // Create daily breakdown
      final List<DailyStats> dailyBreakdown = [];
      for (int i = 0; i < daysInMonth; i++) {
        final day = startOfMonth.add(Duration(days: i));
        final dateKey = '${day.year}-${day.month}-${day.day}';
        final dayLogs = logsByDay[dateKey] ?? [];

        double dayTotal = 0;
        double dayHealthy = 0;
        double dayJunk = 0;
        for (final log in dayLogs) {
          dayTotal += log.calories;
          if (log.isJunk) {
            dayJunk += log.calories;
          } else {
            dayHealthy += log.calories;
          }
        }

        dailyBreakdown.add(DailyStats(
          date: day,
          totalCalories: dayTotal,
          healthyCalories: dayHealthy,
          junkCalories: dayJunk,
          totalItems: dayLogs.length,
          topJunkFoods: [],
        ));
      }

      final daysTracked = logsByDay.keys.length;

      return Right(MonthlyStats(
        year: year,
        month: month,
        totalCalories: logs.totalCalories,
        averageDailyCalories:
            daysTracked > 0 ? logs.totalCalories / daysTracked : 0,
        healthyCalories: logs.healthyCalories,
        junkCalories: logs.junkCalories,
        totalDaysTracked: daysTracked,
        dailyBreakdown: dailyBreakdown,
        topJunkFoods: logs.getTopJunkFoods(),
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
