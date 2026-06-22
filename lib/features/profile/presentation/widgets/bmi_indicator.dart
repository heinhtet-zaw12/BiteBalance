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
        // BMI Value — purple theme gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppTheme.primary,
              AppTheme.primaryLight,
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
        const SizedBox(height: 20),

        // BMI Scale with gradient indicator
        _buildBmiScale(context, color),
      ],
    );
  }

  Widget _buildBmiScale(BuildContext context, Color color) {
    return Column(
      children: [
        Stack(
          children: [
            // Background gradient track
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.bmiUnderweight.withValues(alpha: 0.3),
                      AppTheme.bmiNormal.withValues(alpha: 0.3),
                      AppTheme.bmiOverweight.withValues(alpha: 0.3),
                      AppTheme.bmiObese.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
            // Active progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (bmi.clamp(15, 40) - 15) / 25,
                minHeight: 10,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildScaleLabel(context, 'Underweight', AppTheme.bmiUnderweight),
            _buildScaleLabel(context, 'Normal', AppTheme.bmiNormal),
            _buildScaleLabel(context, 'Overweight', AppTheme.bmiOverweight),
            _buildScaleLabel(context, 'Obese', AppTheme.bmiObese),
          ],
        ),
      ],
    );
  }

  Widget _buildScaleLabel(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 9,
              ),
        ),
      ],
    );
  }
}
