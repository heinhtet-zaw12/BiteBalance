import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/features/analytics/domain/entities/analytics_stats.dart';
import 'package:bite_balance/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:bite_balance/features/analytics/presentation/widgets/calorie_progress_card.dart';
import 'package:bite_balance/features/analytics/presentation/widgets/healthy_junk_pie_chart.dart';
import 'package:bite_balance/features/analytics/presentation/widgets/junk_food_bar_chart.dart';
import 'package:bite_balance/features/profile/presentation/providers/profile_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadCurrentTabData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      ref.read(analyticsTabProvider.notifier).state =
          AnalyticsTab.values[_tabController.index];
      _loadCurrentTabData();
    }
  }

  void _loadCurrentTabData() {
    final now = DateTime.now();
    switch (_tabController.index) {
      case 0:
        ref.read(dailyStatsProvider.notifier).loadStats(now);
        break;
      case 1:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        ref.read(weeklyStatsProvider.notifier).loadStats(weekStart);
        break;
      case 2:
        ref
            .read(monthlyStatsProvider.notifier)
            .loadStats(now.year, now.month);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final double calorieTarget = profileState.maybeWhen(
      data: (profile) {
        if (profile?.weight != null &&
            profile?.height != null &&
            profile?.goal != null) {
          return ref.watch(calorieRecommendationProvider).maybeWhen(
                data: (rec) => (rec?.dailyCalorieTarget ?? 2000).toDouble(),
                orElse: () => 2000.0,
              );
        }
        return 2000.0;
      },
      orElse: () => 2000.0,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DailyTab(calorieTarget: calorieTarget),
          _WeeklyTab(calorieTarget: calorieTarget),
          _MonthlyTab(calorieTarget: calorieTarget),
        ],
      ),
    );
  }
}

class _DailyTab extends ConsumerWidget {
  final double calorieTarget;

  const _DailyTab({required this.calorieTarget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(dailyStatsProvider);

    return statsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorWidget(
        message: error.toString(),
        onRetry: () => ref
            .read(dailyStatsProvider.notifier)
            .loadStats(DateTime.now()),
      ),
      data: (stats) {
        if (stats == null) {
          return const Center(child: Text('No data available'));
        }

        return _StatsContent(
          stats: stats,
          calorieTarget: calorieTarget,
          onRefresh: () => ref
              .read(dailyStatsProvider.notifier)
              .loadStats(DateTime.now()),
        );
      },
    );
  }
}

class _WeeklyTab extends ConsumerWidget {
  final double calorieTarget;

  const _WeeklyTab({required this.calorieTarget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(weeklyStatsProvider);

    return statsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorWidget(
        message: error.toString(),
        onRetry: () {
          final now = DateTime.now();
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          ref.read(weeklyStatsProvider.notifier).loadStats(weekStart);
        },
      ),
      data: (stats) {
        if (stats == null) {
          return const Center(child: Text('No data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CalorieProgressCard(
                consumed: stats.totalCalories,
                target: calorieTarget * 7,
                title: 'Weekly Calories',
              ),
              const SizedBox(height: 16),
              HealthyJunkPieChart(
                healthyCalories: stats.healthyCalories,
                junkCalories: stats.junkCalories,
              ),
              const SizedBox(height: 16),
              JunkFoodBarChart(topJunkFoods: stats.topJunkFoods),
              const SizedBox(height: 16),
              _WeeklyBreakdownCard(dailyBreakdown: stats.dailyBreakdown),
            ],
          ),
        );
      },
    );
  }
}

class _MonthlyTab extends ConsumerWidget {
  final double calorieTarget;

  const _MonthlyTab({required this.calorieTarget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(monthlyStatsProvider);

    return statsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorWidget(
        message: error.toString(),
        onRetry: () {
          final now = DateTime.now();
          ref
              .read(monthlyStatsProvider.notifier)
              .loadStats(now.year, now.month);
        },
      ),
      data: (stats) {
        if (stats == null) {
          return const Center(child: Text('No data available'));
        }

        final daysInMonth =
            DateTime(stats.year, stats.month + 1, 0).day;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CalorieProgressCard(
                consumed: stats.totalCalories,
                target: calorieTarget * daysInMonth,
                title: 'Monthly Calories',
              ),
              const SizedBox(height: 16),
              HealthyJunkPieChart(
                healthyCalories: stats.healthyCalories,
                junkCalories: stats.junkCalories,
              ),
              const SizedBox(height: 16),
              JunkFoodBarChart(topJunkFoods: stats.topJunkFoods),
              const SizedBox(height: 16),
              _StatsInfoCard(
                title: 'Monthly Summary',
                items: [
                  _StatsInfoItem(
                    label: 'Days Tracked',
                    value: '${stats.totalDaysTracked}',
                    icon: Icons.calendar_today_rounded,
                  ),
                  _StatsInfoItem(
                    label: 'Avg Daily Calories',
                    value:
                        '${stats.averageDailyCalories.toStringAsFixed(0)} kcal',
                    icon: Icons.trending_up_rounded,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsContent extends StatelessWidget {
  final DailyStats stats;
  final double calorieTarget;
  final VoidCallback onRefresh;

  const _StatsContent({
    required this.stats,
    required this.calorieTarget,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CalorieProgressCard(
              consumed: stats.totalCalories,
              target: calorieTarget,
              title: 'Today\'s Calories',
            ),
            const SizedBox(height: 16),
            HealthyJunkPieChart(
              healthyCalories: stats.healthyCalories,
              junkCalories: stats.junkCalories,
            ),
            const SizedBox(height: 16),
            JunkFoodBarChart(topJunkFoods: stats.topJunkFoods),
            const SizedBox(height: 16),
            _StatsInfoCard(
              title: 'Today\'s Summary',
              items: [
                _StatsInfoItem(
                  label: 'Total Items',
                  value: '${stats.totalItems}',
                  icon: Icons.restaurant_rounded,
                ),
                _StatsInfoItem(
                  label: 'Healthy',
                  value:
                      '${stats.healthyRatio * 100}%',
                  icon: Icons.favorite_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBreakdownCard extends StatelessWidget {
  final List<DailyStats> dailyBreakdown;

  const _WeeklyBreakdownCard({required this.dailyBreakdown});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ...dailyBreakdown.map((day) {
              final dayName = _getDayName(day.date.weekday);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        dayName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: day.totalCalories > 0
                              ? (day.totalCalories / 2000).clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 8,
                          backgroundColor: AppTheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            day.junkCalories > day.healthyCalories
                                ? AppTheme.error
                                : AppTheme.success,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${day.totalCalories.toStringAsFixed(0)} kcal',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}

class _StatsInfoCard extends StatelessWidget {
  final String title;
  final List<_StatsInfoItem> items;

  const _StatsInfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.icon,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        item.value,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _StatsInfoItem {
  final String label;
  final String value;
  final IconData icon;

  const _StatsInfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
