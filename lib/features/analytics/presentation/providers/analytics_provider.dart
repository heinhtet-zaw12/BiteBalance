import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bite_balance/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:bite_balance/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:bite_balance/features/analytics/domain/entities/analytics_stats.dart';
import 'package:bite_balance/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:bite_balance/features/analytics/domain/usecases/get_daily_stats.dart';
import 'package:bite_balance/features/analytics/domain/usecases/get_weekly_stats.dart';
import 'package:bite_balance/features/analytics/domain/usecases/get_monthly_stats.dart';
import 'package:bite_balance/features/auth/presentation/providers/auth_provider.dart';

// Data source provider
final analyticsRemoteDataSourceProvider =
    Provider<AnalyticsRemoteDataSource>((ref) {
  return AnalyticsRemoteDataSourceImpl(Supabase.instance.client);
});

// Repository provider
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(
    remoteDataSource: ref.read(analyticsRemoteDataSourceProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});

// Use case providers
final getDailyStatsProvider = Provider<GetDailyStats>((ref) {
  return GetDailyStats(ref.read(analyticsRepositoryProvider));
});

final getWeeklyStatsProvider = Provider<GetWeeklyStats>((ref) {
  return GetWeeklyStats(ref.read(analyticsRepositoryProvider));
});

final getMonthlyStatsProvider = Provider<GetMonthlyStats>((ref) {
  return GetMonthlyStats(ref.read(analyticsRepositoryProvider));
});

// Tab selection
enum AnalyticsTab { daily, weekly, monthly }

final analyticsTabProvider = StateProvider<AnalyticsTab>((ref) {
  // Reset tab when user changes (logout or different user login)
  ref.listen(authProvider, (previous, next) {
    if (previous?.value?.id != next.value?.id) {
      ref.invalidateSelf();
    }
  });

  return AnalyticsTab.daily;
});

// Daily stats notifier
class DailyStatsNotifier extends AsyncNotifier<DailyStats?> {
  @override
  Future<DailyStats?> build() async {
    // Invalidate self when user changes (logout or different user login)
    ref.listen(authProvider, (previous, next) {
      if (previous?.value?.id != next.value?.id) {
        ref.invalidateSelf();
      }
    });

    return null;
  }

  Future<void> loadStats(DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getDailyStatsProvider)(
        GetDailyStatsParams(date: date),
      );
      return result.fold(
        (failure) => throw failure,
        (stats) => stats,
      );
    });
  }
}

final dailyStatsProvider =
    AsyncNotifierProvider<DailyStatsNotifier, DailyStats?>(
        DailyStatsNotifier.new);

// Weekly stats notifier
class WeeklyStatsNotifier extends AsyncNotifier<WeeklyStats?> {
  @override
  Future<WeeklyStats?> build() async {
    // Invalidate self when user changes (logout or different user login)
    ref.listen(authProvider, (previous, next) {
      if (previous?.value?.id != next.value?.id) {
        ref.invalidateSelf();
      }
    });

    return null;
  }

  Future<void> loadStats(DateTime weekStart) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getWeeklyStatsProvider)(
        GetWeeklyStatsParams(weekStart: weekStart),
      );
      return result.fold(
        (failure) => throw failure,
        (stats) => stats,
      );
    });
  }
}

final weeklyStatsProvider =
    AsyncNotifierProvider<WeeklyStatsNotifier, WeeklyStats?>(
        WeeklyStatsNotifier.new);

// Monthly stats notifier
class MonthlyStatsNotifier extends AsyncNotifier<MonthlyStats?> {
  @override
  Future<MonthlyStats?> build() async {
    // Invalidate self when user changes (logout or different user login)
    ref.listen(authProvider, (previous, next) {
      if (previous?.value?.id != next.value?.id) {
        ref.invalidateSelf();
      }
    });

    return null;
  }

  Future<void> loadStats(int year, int month) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getMonthlyStatsProvider)(
        GetMonthlyStatsParams(year: year, month: month),
      );
      return result.fold(
        (failure) => throw failure,
        (stats) => stats,
      );
    });
  }
}

final monthlyStatsProvider =
    AsyncNotifierProvider<MonthlyStatsNotifier, MonthlyStats?>(
        MonthlyStatsNotifier.new);
