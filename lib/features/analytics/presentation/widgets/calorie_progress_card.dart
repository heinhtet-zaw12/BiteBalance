import 'package:flutter/material.dart';
import 'package:bite_balance/core/constants/app_theme.dart';

class CalorieProgressCard extends StatelessWidget {
  final double consumed;
  final double target;
  final String title;

  const CalorieProgressCard({
    super.key,
    required this.consumed,
    required this.target,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final remaining = target - consumed;
    final isOver = remaining < 0;

    Color progressColor = AppTheme.success;
    if (isOver) {
      progressColor = AppTheme.error;
    } else if (remaining < 200) {
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'Eaten',
                  value: consumed.toStringAsFixed(0),
                  unit: 'kcal',
                  color: AppTheme.primary,
                ),
                _StatItem(
                  label: 'Target',
                  value: target.toStringAsFixed(0),
                  unit: 'kcal',
                  color: AppTheme.textSecondary,
                ),
                _StatItem(
                  label: isOver ? 'Over' : 'Remaining',
                  value: isOver
                      ? (-remaining).toStringAsFixed(0)
                      : remaining.toStringAsFixed(0),
                  unit: 'kcal',
                  color: progressColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Progress bar with gradient
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              progressColor,
                              progressColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% of target',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOver ? 'Over budget' : 'On track',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
        ),
      ],
    );
  }
}
