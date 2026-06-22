import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/core/utils/responsive.dart';
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
      appBar: Responsive.isDesktop(context)
          ? null
          : AppBar(
              title: const Text('Analytics'),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'Daily'),
                  Tab(text: 'Weekly'),
                  Tab(text: 'Monthly'),
                ],
              ),
            ),
      body: Responsive.isDesktop(context)
          ? _buildDesktopLayout(context, calorieTarget)
          : TabBarView(
              controller: _tabController,
              children: [
                _DailyTab(calorieTarget: calorieTarget),
                _WeeklyTab(calorieTarget: calorieTarget),
                _MonthlyTab(calorieTarget: calorieTarget),
              ],
            ),
    );
  }

  /// Desktop: tabs as horizontal row above content, not AppBar
  Widget _buildDesktopLayout(BuildContext context, double calorieTarget) {
    return Column(
      children: [
        // Title + Tab row
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
          child: Row(
            children: [
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primary,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Daily'),
                      Tab(text: 'Weekly'),
                      Tab(text: 'Monthly'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _DailyTab(calorieTarget: calorieTarget),
              _WeeklyTab(calorieTarget: calorieTarget),
              _MonthlyTab(calorieTarget: calorieTarget),
            ],
          ),
        ),
      ],
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

        return _ResponsiveChartLayout(
          children: [
            CalorieProgressCard(
              consumed: stats.totalCalories,
              target: calorieTarget * 7,
              title: 'Weekly Calories',
            ),
            HealthyJunkPieChart(
              healthyCalories: stats.healthyCalories,
              junkCalories: stats.junkCalories,
            ),
            JunkFoodBarChart(topJunkFoods: stats.topJunkFoods),
            _WeeklyBreakdownCard(dailyBreakdown: stats.dailyBreakdown),
          ],
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

        return _ResponsiveChartLayout(
          children: [
            CalorieProgressCard(
              consumed: stats.totalCalories,
              target: calorieTarget * daysInMonth,
              title: 'Monthly Calories',
            ),
            HealthyJunkPieChart(
              healthyCalories: stats.healthyCalories,
              junkCalories: stats.junkCalories,
            ),
            JunkFoodBarChart(topJunkFoods: stats.topJunkFoods),
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
        );
      },
    );
  }
}

/// Responsive chart layout:
/// - Mobile: single column, stacked
/// - Tablet/Desktop: 2-column grid for charts
class _ResponsiveChartLayout extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveChartLayout({required this.children});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    if (!Responsive.isWide(context)) {
      // Mobile: single column
      return SingleChildScrollView(
        padding: padding,
        child: Column(
          children: children
              .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: c,
                  ))
              .toList(),
        ),
      );
    }

    // Tablet/Desktop: 2-column grid
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        children: [
          // First row: progress + pie chart side by side
          if (children.length >= 2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 16),
                Expanded(child: children[1]),
              ],
            ),
          if (children.length >= 2) const SizedBox(height: 16),
          // Remaining cards
          ...children.skip(2).map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: c,
              )),
        ],
      ),
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
      child: _ResponsiveChartLayout(
        children: [
          CalorieProgressCard(
            consumed: stats.totalCalories,
            target: calorieTarget,
            title: 'Today\'s Calories',
          ),
          HealthyJunkPieChart(
            healthyCalories: stats.healthyCalories,
            junkCalories: stats.junkCalories,
          ),
          JunkFoodBarChart(topJunkFoods: stats.topJunkFoods),
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
                    '${(stats.healthyRatio * 100).toStringAsFixed(0)}%',
                icon: Icons.favorite_rounded,
              ),
            ],
          ),
        ],
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_view_week_rounded,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Weekly Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: day.totalCalories > 0
                                    ? (day.totalCalories / 2000)
                                        .clamp(0.0, 1.0)
                                    : 0.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: day.junkCalories >
                                            day.healthyCalories
                                        ? AppTheme.error
                                        : AppTheme.success,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
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
        padding: const EdgeInsets.all(24),
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
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: items
                    .map((item) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                item.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
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
