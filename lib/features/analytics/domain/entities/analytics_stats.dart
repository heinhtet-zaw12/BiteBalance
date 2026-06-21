class DailyStats {
  final DateTime date;
  final double totalCalories;
  final double healthyCalories;
  final double junkCalories;
  final int totalItems;
  final List<FoodItemStats> topJunkFoods;

  const DailyStats({
    required this.date,
    required this.totalCalories,
    required this.healthyCalories,
    required this.junkCalories,
    required this.totalItems,
    required this.topJunkFoods,
  });

  double get healthyRatio =>
      totalCalories > 0 ? healthyCalories / totalCalories : 0;
  double get junkRatio =>
      totalCalories > 0 ? junkCalories / totalCalories : 0;
}

class WeeklyStats {
  final DateTime startDate;
  final DateTime endDate;
  final double totalCalories;
  final double averageDailyCalories;
  final double healthyCalories;
  final double junkCalories;
  final List<DailyStats> dailyBreakdown;
  final List<FoodItemStats> topJunkFoods;

  const WeeklyStats({
    required this.startDate,
    required this.endDate,
    required this.totalCalories,
    required this.averageDailyCalories,
    required this.healthyCalories,
    required this.junkCalories,
    required this.dailyBreakdown,
    required this.topJunkFoods,
  });

  double get healthyRatio =>
      totalCalories > 0 ? healthyCalories / totalCalories : 0;
  double get junkRatio =>
      totalCalories > 0 ? junkCalories / totalCalories : 0;
}

class MonthlyStats {
  final int year;
  final int month;
  final double totalCalories;
  final double averageDailyCalories;
  final double healthyCalories;
  final double junkCalories;
  final int totalDaysTracked;
  final List<DailyStats> dailyBreakdown;
  final List<FoodItemStats> topJunkFoods;

  const MonthlyStats({
    required this.year,
    required this.month,
    required this.totalCalories,
    required this.averageDailyCalories,
    required this.healthyCalories,
    required this.junkCalories,
    required this.totalDaysTracked,
    required this.dailyBreakdown,
    required this.topJunkFoods,
  });

  double get healthyRatio =>
      totalCalories > 0 ? healthyCalories / totalCalories : 0;
  double get junkRatio =>
      totalCalories > 0 ? junkCalories / totalCalories : 0;
}

class FoodItemStats {
  final String foodName;
  final int count;
  final double totalCalories;

  const FoodItemStats({
    required this.foodName,
    required this.count,
    required this.totalCalories,
  });
}
