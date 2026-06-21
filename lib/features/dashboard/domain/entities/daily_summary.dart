import 'package:bite_balance/features/food_log/domain/entities/food_log.dart';

class DailySummary {
  final DateTime date;
  final List<FoodLog> foodLogs;

  const DailySummary({
    required this.date,
    required this.foodLogs,
  });

  double get totalCalories =>
      foodLogs.fold(0, (sum, log) => sum + log.calories);

  double get healthyCalories =>
      foodLogs.where((log) => !log.isJunk).fold(0, (sum, log) => sum + log.calories);

  double get junkCalories =>
      foodLogs.where((log) => log.isJunk).fold(0, (sum, log) => sum + log.calories);

  int get healthyCount => foodLogs.where((log) => !log.isJunk).length;

  int get junkCount => foodLogs.where((log) => log.isJunk).length;
}
