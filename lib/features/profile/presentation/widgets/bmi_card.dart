import 'package:flutter/material.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/features/profile/domain/entities/profile.dart';
import 'package:bite_balance/features/profile/domain/usecases/calculate_bmi.dart';
import 'package:bite_balance/features/profile/presentation/widgets/bmi_indicator.dart';

class BmiCard extends StatelessWidget {
  final Profile profile;
  final CalculateBmi calculateBmi;

  const BmiCard({
    super.key,
    required this.profile,
    required this.calculateBmi,
  });

  @override
  Widget build(BuildContext context) {
    if (profile.weight == null || profile.height == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 32,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Complete your profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Update your weight and height to see your BMI',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final bmi = calculateBmi(profile.weight!, profile.height!);
    final category = calculateBmi.getCategory(bmi);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Text(
              'Your BMI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            BmiIndicator(bmi: bmi, category: category),
            const SizedBox(height: 28),

            // Stats Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.04),
                    AppTheme.primaryLight.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: Icons.monitor_weight_outlined,
                      label: 'Weight',
                      value: '${profile.weight!.toStringAsFixed(1)} kg',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.divider,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: Icons.height,
                      label: 'Height',
                      value: '${profile.height!.toStringAsFixed(1)} cm',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
