import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bite_balance/features/dashboard/presentation/widgets/calorie_summary_card.dart';
import 'package:bite_balance/features/dashboard/presentation/widgets/healthy_junk_chart.dart';
import 'package:bite_balance/features/dashboard/presentation/widgets/food_log_tile.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(dashboardProvider.notifier).loadSummary();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/food-log');
          if (mounted) {
            ref.read(dashboardProvider.notifier).loadSummary();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Food'),
      ),
      body: summaryState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(dashboardProvider.notifier).loadSummary();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (summary) {
          if (summary == null) {
            return const Center(child: Text('No data'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(dashboardProvider.notifier).loadSummary();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Text(
                    _formatDate(summary.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),

                  // Calorie Summary
                  CalorieSummaryCard(
                    totalCalories: summary.totalCalories,
                    totalItems: summary.foodLogs.length,
                  ),
                  const SizedBox(height: 16),

                  // Healthy vs Junk Chart
                  HealthyJunkChart(
                    healthyCalories: summary.healthyCalories,
                    junkCalories: summary.junkCalories,
                  ),
                  const SizedBox(height: 24),

                  // Food Log List Header
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Food Log',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      if (summary.foodLogs.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${summary.foodLogs.length} items',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (summary.foodLogs.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.restaurant_outlined,
                                  size: 32,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No food logged today',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start tracking your meals',
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => context.push('/food-log'),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Log Your First Meal'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...summary.foodLogs.map(
                      (log) => FoodLogTile(foodLog: log),
                    ),

                  // Bottom spacing for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
