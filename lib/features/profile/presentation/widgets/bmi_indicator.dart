import 'package:flutter/material.dart';
import 'package:bite_balance/core/constants/app_theme.dart';

class BmiIndicator extends StatelessWidget {
  final double bmi;
  final String category;

  const BmiIndicator({
    super.key,
    required this.bmi,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getBmiColor(bmi);

    return Column(
      children: [
        // BMI Value
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.7),
            ],
          ).createShader(bounds),
          child: Text(
            bmi.toStringAsFixed(1),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
          ),
        ),
        const SizedBox(height: 12),

        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 16),

        // BMI Scale
        _buildBmiScale(context, color),
      ],
    );
  }

  Widget _buildBmiScale(BuildContext context, Color color) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (bmi.clamp(15, 40) - 15) / 25,
            minHeight: 8,
            backgroundColor: AppTheme.divider,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '15',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '40',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}
