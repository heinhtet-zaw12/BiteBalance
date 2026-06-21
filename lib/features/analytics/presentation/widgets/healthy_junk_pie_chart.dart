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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Healthy vs Junk',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      value: healthyCalories > 0 ? healthyCalories : 1,
                      color: AppTheme.success,
                      title: '${healthyPercent.toStringAsFixed(0)}%',
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: junkCalories > 0 ? junkCalories : 0.1,
                      color: AppTheme.error,
                      title: junkCalories > 0
                          ? '${junkPercent.toStringAsFixed(0)}%'
                          : '',
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(
                  color: AppTheme.success,
                  label: 'Healthy',
                  value: '${healthyCalories.toStringAsFixed(0)} kcal',
                ),
                const SizedBox(width: 24),
                _LegendItem(
                  color: AppTheme.error,
                  label: 'Junk',
                  value: '${junkCalories.toStringAsFixed(0)} kcal',
                ),
              ],
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

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
