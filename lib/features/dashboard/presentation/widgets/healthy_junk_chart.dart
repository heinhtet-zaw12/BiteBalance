import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bite_balance/core/constants/app_theme.dart';

class HealthyJunkChart extends StatelessWidget {
  final double healthyCalories;
  final double junkCalories;

  const HealthyJunkChart({
    super.key,
    required this.healthyCalories,
    required this.junkCalories,
  });

  @override
  Widget build(BuildContext context) {
    final total = healthyCalories + junkCalories;

    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Healthy vs Junk',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.pie_chart_outline,
                  size: 40,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No data yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Log food to see breakdown',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    final healthyPercent = (healthyCalories / total * 100).toStringAsFixed(0);
    final junkPercent = (junkCalories / total * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pie_chart_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Healthy vs Junk',
                  style: Theme.of(context).textTheme.titleMedium,
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
                      value: healthyCalories,
                      color: AppTheme.success,
                      radius: 55,
                      showTitle: false,
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    PieChartSectionData(
                      value: junkCalories,
                      color: AppTheme.error,
                      radius: 55,
                      showTitle: false,
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildLegend(
                    context,
                    color: AppTheme.success,
                    label: 'Healthy',
                    percent: '$healthyPercent%',
                    calories: '${healthyCalories.toStringAsFixed(0)} kcal',
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 56,
                  color: AppTheme.divider,
                ),
                Expanded(
                  child: _buildLegend(
                    context,
                    color: AppTheme.error,
                    label: 'Junk',
                    percent: '$junkPercent%',
                    calories: '${junkCalories.toStringAsFixed(0)} kcal',
                    icon: Icons.warning_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(
    BuildContext context, {
    required Color color,
    required String label,
    required String percent,
    required String calories,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          percent,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(
          calories,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
