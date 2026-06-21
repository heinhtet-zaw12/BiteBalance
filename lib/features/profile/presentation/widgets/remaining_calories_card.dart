import 'package:flutter/material.dart';
import 'package:bite_balance/core/constants/app_theme.dart';

class RemainingCaloriesCard extends StatelessWidget {
  final double caloriesConsumed;
  final double calorieTarget;

  const RemainingCaloriesCard({
    super.key,
    required this.caloriesConsumed,
    required this.calorieTarget,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = calorieTarget - caloriesConsumed;
    final progress = calorieTarget > 0
        ? (caloriesConsumed / calorieTarget).clamp(0.0, 1.0)
        : 0.0;
    final isOverTarget = remaining < 0;
    final isNearTarget = remaining > 0 && remaining < 200;

    Color progressColor = AppTheme.success;
    if (isOverTarget) {
      progressColor = AppTheme.error;
    } else if (isNearTarget) {
      progressColor = AppTheme.bmiOverweight;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOverTarget
                        ? Icons.warning_rounded
                        : Icons.track_changes_rounded,
                    color: progressColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOverTarget ? 'Over Target!' : 'Remaining Today',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOverTarget
                            ? '${(-remaining).toStringAsFixed(0)} kcal over'
                            : '${remaining.toStringAsFixed(0)} kcal left',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: progressColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppTheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${caloriesConsumed.toStringAsFixed(0)} kcal eaten',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Text(
                  '${calorieTarget.toStringAsFixed(0)} kcal target',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
