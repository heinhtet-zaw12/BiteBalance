import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bite_balance/features/food_log/data/models/food_log_model.dart';

abstract class FoodLogRemoteDataSource {
  Future<FoodLogModel> logFood(FoodLogModel foodLog);
  Future<List<FoodLogModel>> getDailyLogs(String userId, DateTime date);
  Future<void> deleteFoodLog(String userId, String id);
}

class FoodLogRemoteDataSourceImpl implements FoodLogRemoteDataSource {
  final SupabaseClient client;

  FoodLogRemoteDataSourceImpl(this.client);

  @override
  Future<FoodLogModel> logFood(FoodLogModel foodLog) async {
    final response = await client
        .from('food_logs')
        .insert(foodLog.toJson())
        .select()
        .single();

    return FoodLogModel.fromJson(response);
  }

  @override
  Future<List<FoodLogModel>> getDailyLogs(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await client
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .gte('created_at', startOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String())
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => FoodLogModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteFoodLog(String userId, String id) async {
    await client
        .from('food_logs')
        .delete()
        .eq('user_id', userId)
        .eq('id', id);
  }
}
