import 'package:flutter/material.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/features/food_log/domain/entities/food_log.dart';

class FoodLogTile extends StatelessWidget {
  final FoodLog foodLog;

  const FoodLogTile({super.key, required this.foodLog});

  @override
  Widget build(BuildContext context) {
    final isJunk = foodLog.isJunk;
    final statusColor = isJunk ? AppTheme.error : AppTheme.success;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Food Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: isJunk
                  ? Icon(Icons.fastfood_rounded, color: statusColor, size: 24)
                  : Image.asset('assets/images/bite_balance_logo.png', width: 24, height: 24),
            ),
            const SizedBox(width: 14),

            // Food Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodLog.foodName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: _getMealIcon(foodLog.mealType),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getMealTypeLabel(foodLog.mealType),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Calories and Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      foodLog.calories.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'kcal',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isJunk ? 'Junk' : 'Healthy',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMealTypeLabel(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return mealType;
    }
  }

  Widget _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return const Icon(Icons.free_breakfast_rounded, size: 12, color: AppTheme.textTertiary);
      case 'lunch':
        return const Icon(Icons.lunch_dining_rounded, size: 12, color: AppTheme.textTertiary);
      case 'dinner':
        return const Icon(Icons.dinner_dining_rounded, size: 12, color: AppTheme.textTertiary);
      case 'snack':
        return const Icon(Icons.cookie_rounded, size: 12, color: AppTheme.textTertiary);
      default:
        return Image.asset('assets/images/bite_balance_logo.png', width: 12, height: 12);
    }
  }
}
