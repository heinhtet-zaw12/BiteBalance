import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/core/utils/responsive.dart';
import 'package:bite_balance/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bite_balance/features/dashboard/presentation/widgets/calorie_summary_card.dart';
import 'package:bite_balance/features/dashboard/presentation/widgets/healthy_junk_chart.dart';
import 'package:bite_balance/features/dashboard/presentation/widgets/food_log_tile.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).loadSummary();
    });

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimations = List.generate(5, (index) {
      final start = (index * 0.12).clamp(0.0, 1.0);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnimations = List.generate(5, (index) {
      final start = (index * 0.12).clamp(0.0, 1.0);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedChild(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(dashboardProvider);
    final isWide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: Responsive.isDesktop(context)
          ? null // No AppBar on desktop — sidebar handles branding
          : AppBar(
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

          // Start stagger animation
          if (!_staggerController.isCompleted) {
            _staggerController.forward();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(dashboardProvider.notifier).loadSummary();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: Responsive.pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desktop: title row (since no AppBar)
                  if (Responsive.isDesktop(context)) ...[
                    Row(
                      children: [
                        Text(
                          'Dashboard',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: () {
                            ref
                                .read(dashboardProvider.notifier)
                                .loadSummary();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Date Header
                  _buildAnimatedChild(
                    0,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDate(summary.date),
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.primary,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tablet/Desktop: Calorie summary + Chart side by side
                  if (isWide)
                    _buildAnimatedChild(
                      1,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CalorieSummaryCard(
                              totalCalories: summary.totalCalories,
                              totalItems: summary.foodLogs.length,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: HealthyJunkChart(
                              healthyCalories: summary.healthyCalories,
                              junkCalories: summary.junkCalories,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Mobile: stacked
                    _buildAnimatedChild(
                      1,
                      CalorieSummaryCard(
                        totalCalories: summary.totalCalories,
                        totalItems: summary.foodLogs.length,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedChild(
                      2,
                      HealthyJunkChart(
                        healthyCalories: summary.healthyCalories,
                        junkCalories: summary.junkCalories,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Food Log List Header
                  _buildAnimatedChild(
                    isWide ? 2 : 3,
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Food Log',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        if (summary.foodLogs.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
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
                  ),
                  const SizedBox(height: 12),

                  // Food log items or empty state
                  _buildAnimatedChild(
                    isWide ? 3 : 4,
                    summary.foodLogs.isEmpty
                        ? _buildEmptyState(context)
                        : _buildFoodLogGrid(context, summary.foodLogs),
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

  /// Responsive food log grid:
  /// - Mobile: single column
  /// - Tablet/Desktop: 2-column grid
  Widget _buildFoodLogGrid(BuildContext context, List<dynamic> foodLogs) {
    if (!Responsive.isWide(context)) {
      // Mobile: single column
      return Column(
        children: foodLogs
            .map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FoodLogTile(foodLog: log),
                ))
            .toList(),
      );
    }

    // Tablet/Desktop: 2-column grid
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: Responsive.isDesktop(context) ? 3.2 : 2.8,
      ),
      itemCount: foodLogs.length,
      itemBuilder: (context, index) => FoodLogTile(foodLog: foodLogs[index]),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.restaurant_outlined,
                  size: 36,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No food logged today',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your meals',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.push('/food-log'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Log Your First Meal'),
              ),
            ],
          ),
        ),
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
