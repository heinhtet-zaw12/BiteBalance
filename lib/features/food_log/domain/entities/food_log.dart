class FoodLog {
  final String id;
  final String userId;
  final String foodName;
  final double calories;
  final bool isJunk;
  final String mealType;
  final DateTime createdAt;

  const FoodLog({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    this.isJunk = false,
    required this.mealType,
    required this.createdAt,
  });
}
