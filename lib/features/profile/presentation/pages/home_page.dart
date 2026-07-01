import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/core/utils/error_handler.dart';
import 'package:bite_balance/core/utils/responsive.dart';
import 'package:bite_balance/features/auth/presentation/providers/auth_provider.dart';
import 'package:bite_balance/features/food_log/domain/entities/food_log.dart';
import 'package:bite_balance/features/food_log/presentation/providers/food_log_provider.dart';
import 'package:bite_balance/features/profile/presentation/providers/profile_provider.dart';
import 'package:bite_balance/features/profile/presentation/widgets/bmi_card.dart';
import 'package:bite_balance/features/profile/presentation/widgets/calorie_target_card.dart';
import 'package:bite_balance/features/profile/presentation/widgets/remaining_calories_card.dart';
import 'package:bite_balance/core/widgets/shimmer_loading.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimations = List.generate(8, (index) {
      final start = (index * 0.08).clamp(0.0, 1.0);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnimations = List.generate(8, (index) {
      final start = (index * 0.08).clamp(0.0, 1.0);
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
    final profileState = ref.watch(profileProvider);
    final calculateBmi = ref.read(calculateBmiProvider);
    final calorieRecommendationState = ref.watch(calorieRecommendationProvider);
    final dailyLogsState = ref.watch(dailyLogsProvider);
    final isWide = Responsive.isWide(context);

    // Load calorie recommendation when profile is available
    ref.listen(profileProvider, (previous, next) {
      next.whenData((profile) {
        if (profile != null &&
            profile.weight != null &&
            profile.height != null &&
            profile.goal != null) {
          Future.microtask(() {
            ref.read(calorieRecommendationProvider.notifier).loadRecommendation(
                  weightKg: profile.weight!,
                  heightCm: profile.height!,
                  goal: profile.goal!,
                );
            ref.read(dailyLogsProvider.notifier).loadLogs(DateTime.now());
          });
        }
      });
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: Responsive.isDesktop(context)
          ? null
          : AppBar(
              title: const Text('Bite Balance'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.go('/profile-setup'),
                  tooltip: 'Edit Profile',
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/food-log'),
        icon: const Icon(Icons.add),
        label: const Text('Log Food'),
      ),
      body: profileState.when(
        loading: () => const HomeShimmer(),
        error: (error, stackTrace) => Center(
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
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  ErrorHandler.message(error),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(profileProvider.notifier).loadProfile(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome!',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set up your profile to get started',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go('/profile-setup'),
                      child: const Text('Setup Profile'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Start stagger animation when data loads
          if (!_staggerController.isCompleted) {
            _staggerController.forward();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(profileProvider.notifier).loadProfile();
            },
            child: SingleChildScrollView(
                primary: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: Responsive.pagePadding(context),
              child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desktop: title row + edit + logout
                  if (Responsive.isDesktop(context)) ...[
                    Row(
                      children: [
                        Text(
                          'Bite Balance',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => context.go('/profile-setup'),
                          tooltip: 'Edit Profile',
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          onPressed: () async {
                            await ref.read(authProvider.notifier).signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Greeting
                  _buildAnimatedChild(
                    0,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${profile.fullName ?? 'User'}! 👋',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here\'s your health summary',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tablet/Desktop: BMI + Calorie Target side by side
                  if (isWide)
                    _buildAnimatedChild(
                      1,
                      _buildWideTopSection(
                        context,
                        profile: profile,
                        calculateBmi: calculateBmi,
                        calorieRecommendationState:
                            calorieRecommendationState,
                        dailyLogsState: dailyLogsState,
                      ),
                    )
                  else ...[
                    // Mobile: stacked
                    _buildAnimatedChild(
                      1,
                      BmiCard(
                        profile: profile,
                        calculateBmi: calculateBmi,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildCalorieCards(
                      context,
                      index: 2,
                      calorieRecommendationState:
                          calorieRecommendationState,
                      dailyLogsState: dailyLogsState,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Goal Card
                  _buildAnimatedChild(
                    4,
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.flag_rounded,
                                color: AppTheme.accent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Goal',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getGoalText(profile.goal),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tablet/Desktop: Action cards side by side
                  if (isWide)
                    _buildAnimatedChild(
                      5,
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.restaurant_rounded,
                              iconColor: AppTheme.primary,
                              title: 'Log Your Food',
                              subtitle: 'Let AI analyze your meals',
                              onTap: () => context.push('/food-log'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.dashboard_rounded,
                              iconColor: AppTheme.secondary,
                              title: 'View Dashboard',
                              subtitle: 'Track your daily calories',
                              onTap: () => context.push('/dashboard'),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    _buildAnimatedChild(
                      5,
                      _ActionCard(
                        icon: Icons.restaurant_rounded,
                        iconColor: AppTheme.primary,
                        title: 'Log Your Food',
                        subtitle: 'Let AI analyze your meals',
                        onTap: () => context.push('/food-log'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedChild(
                      6,
                      _ActionCard(
                        icon: Icons.dashboard_rounded,
                        iconColor: AppTheme.secondary,
                        title: 'View Dashboard',
                        subtitle: 'Track your daily calories',
                        onTap: () => context.push('/dashboard'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
              ),
            ),
          ),
      );
        },
      ),
    );
  }

  /// Wide layout: BMI card + Calorie target + Remaining in a row
  Widget _buildWideTopSection(
    BuildContext context, {
    required dynamic profile,
    required dynamic calculateBmi,
    required AsyncValue calorieRecommendationState,
    required AsyncValue<List<FoodLog>> dailyLogsState,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BmiCard(
                profile: profile,
                calculateBmi: calculateBmi,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCalorieColumn(
                context,
                calorieRecommendationState: calorieRecommendationState,
                dailyLogsState: dailyLogsState,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalorieColumn(
    BuildContext context, {
    required AsyncValue calorieRecommendationState,
    required AsyncValue<List<FoodLog>> dailyLogsState,
  }) {
    return calorieRecommendationState.when(
      loading: () => const CalorieCardShimmer(),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.error,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  ErrorHandler.message(error),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
      data: (recommendation) {
        if (recommendation == null) {
          return const SizedBox.shrink();
        }

        final caloriesConsumed = dailyLogsState.maybeWhen(
          data: (List<FoodLog> logs) => logs.fold<double>(
            0.0,
            (double sum, FoodLog log) => sum + log.calories.toDouble(),
          ),
          orElse: () => 0.0,
        );

        return Column(
          children: [
            CalorieTargetCard(
              dailyCalorieTarget: recommendation.dailyCalorieTarget,
              healthyRatio: recommendation.healthyRatio,
              reasoning: recommendation.reasoning,
            ),
            const SizedBox(height: 16),
            RemainingCaloriesCard(
              caloriesConsumed: caloriesConsumed,
              calorieTarget: recommendation.dailyCalorieTarget,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCalorieCards(
    BuildContext context, {
    required int index,
    required AsyncValue calorieRecommendationState,
    required AsyncValue<List<FoodLog>> dailyLogsState,
  }) {
    return [
      calorieRecommendationState.when(
        loading: () => _buildAnimatedChild(
          index,
          const CalorieCardShimmer(),
        ),
        error: (error, _) => _buildAnimatedChild(
          index,
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppTheme.error,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ErrorHandler.message(error),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        data: (recommendation) {
          if (recommendation == null) {
            return const SizedBox.shrink();
          }

          final caloriesConsumed = dailyLogsState.maybeWhen(
            data: (List<FoodLog> logs) => logs.fold<double>(
              0.0,
              (double sum, FoodLog log) => sum + log.calories.toDouble(),
            ),
            orElse: () => 0.0,
          );

          return Column(
            children: [
              _buildAnimatedChild(
                index,
                CalorieTargetCard(
                  dailyCalorieTarget: recommendation.dailyCalorieTarget,
                  healthyRatio: recommendation.healthyRatio,
                  reasoning: recommendation.reasoning,
                ),
              ),
              const SizedBox(height: 16),
              _buildAnimatedChild(
                index + 1,
                RemainingCaloriesCard(
                  caloriesConsumed: caloriesConsumed,
                  calorieTarget: recommendation.dailyCalorieTarget,
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    ];
  }

  String _getGoalText(String? goal) {
    switch (goal) {
      case 'lose':
        return 'Lose Weight';
      case 'gain':
        return 'Gain Weight';
      case 'maintain':
      default:
        return 'Maintain Weight';
    }
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
