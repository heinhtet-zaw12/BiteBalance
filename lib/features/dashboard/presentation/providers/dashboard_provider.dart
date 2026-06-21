import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bite_balance/features/dashboard/domain/entities/daily_summary.dart';
import 'package:bite_balance/features/dashboard/domain/usecases/get_daily_summary.dart';
import 'package:bite_balance/features/food_log/presentation/providers/food_log_provider.dart';

final getDailySummaryProvider = Provider<GetDailySummary>((ref) {
  return GetDailySummary(ref.read(foodLogRepositoryProvider));
});

class DashboardNotifier extends AsyncNotifier<DailySummary?> {
  @override
  Future<DailySummary?> build() async {
    return null;
  }

  Future<void> loadSummary({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(getDailySummaryProvider)(
        GetDailySummaryParams(date: targetDate),
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (summary) => summary,
      );
    });
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DailySummary?>(
  DashboardNotifier.new,
);
