import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bite_balance/core/constants/app_theme.dart';

class HealthyJunkPieChart extends StatelessWidget {
  final double healthyCalories;
  final double junkCalories;

  const HealthyJunkPieChart({
    super.key,
    required this.healthyCalories,
    required this.junkCalories,
  });

  @override
  Widget build(BuildContext context) {
    final total = healthyCalories + junkCalories;
    final healthyPercent = total > 0 ? (healthyCalories / total * 100) : 0;
    final junkPercent = total > 0 ? (junkCalories / total * 100) : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Healthy vs Junk',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      value: healthyCalories > 0 ? healthyCalories : 1,
                      color: AppTheme.success,
                      title: '${healthyPercent.toStringAsFixed(0)}%',
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      borderSide: BorderSide(
                        color: AppTheme.background,
                        width: 2,
                      ),
                    ),
                    PieChartSectionData(
                      value: junkCalories > 0 ? junkCalories : 0.1,
                      color: AppTheme.error,
                      title: junkCalories > 0
                          ? '${junkPercent.toStringAsFixed(0)}%'
                          : '',
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      borderSide: BorderSide(
                        color: AppTheme.background,
                        width: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LegendItem(
                    color: AppTheme.success,
                    label: 'Healthy',
                    value: '${healthyCalories.toStringAsFixed(0)} kcal',
                    icon: Icons.check_circle_rounded,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.divider,
                  ),
                  _LegendItem(
                    color: AppTheme.error,
                    label: 'Junk',
                    value: '${junkCalories.toStringAsFixed(0)} kcal',
                    icon: Icons.warning_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final IconData icon;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
