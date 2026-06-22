import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bite_balance/features/analytics/domain/entities/analytics_stats.dart';
import 'package:bite_balance/features/food_log/data/models/food_log_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<List<FoodLogModel>> getLogsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  );
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final SupabaseClient client;

  AnalyticsRemoteDataSourceImpl(this.client);

  @override
  Future<List<FoodLogModel>> getLogsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final response = await client
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .gte('created_at', start.toIso8601String())
        .lt('created_at', end.toIso8601String())
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => FoodLogModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

// Helper extension to convert FoodLogModel list to stats
extension FoodLogStatsExtension on List<FoodLogModel> {
  List<FoodItemStats> getTopJunkFoods({int limit = 3}) {
    // Group by food name and count
    final Map<String, FoodItemStats> grouped = {};
    for (final log in this) {
      if (log.isJunk) {
        final existing = grouped[log.foodName];
        if (existing != null) {
          grouped[log.foodName] = FoodItemStats(
            foodName: log.foodName,
            count: existing.count + 1,
            totalCalories: existing.totalCalories + log.calories,
          );
        } else {
          grouped[log.foodName] = FoodItemStats(
            foodName: log.foodName,
            count: 1,
            totalCalories: log.calories,
          );
        }
      }
    }

    // Sort by count descending and take top N
    final sorted = grouped.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return sorted.take(limit).toList();
  }

  double get totalCalories =>
      fold(0.0, (sum, log) => sum + log.calories);

  double get healthyCalories =>
      fold(0.0, (sum, log) => log.isJunk ? sum : sum + log.calories);

  double get junkCalories =>
      fold(0.0, (sum, log) => log.isJunk ? sum + log.calories : sum);
}
