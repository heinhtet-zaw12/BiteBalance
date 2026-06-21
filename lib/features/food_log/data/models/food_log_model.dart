import 'package:bite_balance/features/food_log/domain/entities/food_log.dart';

class FoodLogModel extends FoodLog {
  const FoodLogModel({
    required super.id,
    required super.userId,
    required super.foodName,
    required super.calories,
    super.isJunk,
    required super.mealType,
    required super.createdAt,
  });

  factory FoodLogModel.fromJson(Map<String, dynamic> json) {
    return FoodLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      foodName: json['food_name'] as String,
      calories: (json['calories'] as num).toDouble(),
      isJunk: json['is_junk'] as bool? ?? false,
      mealType: json['meal_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_name': foodName,
      'calories': calories,
      'is_junk': isJunk,
      'meal_type': mealType,
    };
  }

  factory FoodLogModel.fromEntity(FoodLog foodLog) {
    return FoodLogModel(
      id: foodLog.id,
      userId: foodLog.userId,
      foodName: foodLog.foodName,
      calories: foodLog.calories,
      isJunk: foodLog.isJunk,
      mealType: foodLog.mealType,
      createdAt: foodLog.createdAt,
    );
  }
}
