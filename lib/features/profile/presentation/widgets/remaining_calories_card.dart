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
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
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
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
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
                    // Background
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Progress with gradient
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
            const SizedBox(height: 14),

            // Labels row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel(
                  context,
                  icon: Icons.restaurant_rounded,
                  label: '${caloriesConsumed.toStringAsFixed(0)} kcal eaten',
                ),
                _buildLabel(
                  context,
                  icon: Icons.flag_rounded,
                  label: '${calorieTarget.toStringAsFixed(0)} kcal target',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}
