import 'package:flutter/material.dart';
import 'package:bite_balance/core/constants/app_theme.dart';

class CalorieTargetCard extends StatelessWidget {
  final double dailyCalorieTarget;
  final double healthyRatio;
  final String reasoning;

  const CalorieTargetCard({
    super.key,
    required this.dailyCalorieTarget,
    required this.healthyRatio,
    required this.reasoning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            // Header with icon
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Calorie Target',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Calorie value with glow effect
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFE0D6FF),
                ],
              ).createShader(bounds),
              child: Text(
                dailyCalorieTarget.toStringAsFixed(0),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 56,
                      letterSpacing: -2,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'kcal / day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 20),

            // Healthy food badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(healthyRatio * 100).toStringAsFixed(0)}% healthy food',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reasoning text
            Text(
              reasoning,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
