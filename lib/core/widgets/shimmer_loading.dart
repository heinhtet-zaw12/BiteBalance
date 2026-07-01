import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bite_balance/core/constants/app_theme.dart';

/// Base shimmer wrapper that applies the app's dark theme shimmer effect.
/// All skeleton widgets should use this as their foundation.
class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceVariant,
      highlightColor: AppTheme.surface,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// A rounded rectangle shimmer box used as a generic placeholder.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }
}

/// Full-width shimmer box that takes available width.
class ShimmerLine extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const ShimmerLine({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Dashboard Shimmer
// ═══════════════════════════════════════════════════════════════════

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date badge
            const ShimmerBox(width: 100, height: 32),
            const SizedBox(height: 16),

            // Calorie summary + Chart
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCalorieSummaryCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildChartCard()),
                ],
              )
            else ...[
              _buildCalorieSummaryCard(),
              const SizedBox(height: 16),
              _buildChartCard(),
            ],
            const SizedBox(height: 24),

            // Food Log header
            Row(
              children: [
                const ShimmerBox(width: 32, height: 32),
                const SizedBox(width: 10),
                const ShimmerBox(width: 80, height: 20),
                const Spacer(),
                const ShimmerBox(width: 60, height: 28),
              ],
            ),
            const SizedBox(height: 12),

            // Food log tiles
            _buildFoodLogTile(),
            const SizedBox(height: 8),
            _buildFoodLogTile(),
            const SizedBox(height: 8),
            _buildFoodLogTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerBox(width: 28, height: 28),
                const SizedBox(width: 10),
                const ShimmerBox(width: 120, height: 18),
              ],
            ),
            const SizedBox(height: 24),
            const ShimmerBox(width: 140, height: 36),
            const SizedBox(height: 12),
            const ShimmerLine(height: 10),
            const SizedBox(height: 16),
            Row(
              children: [
                const ShimmerBox(width: 60, height: 28),
                const Spacer(),
                const ShimmerBox(width: 60, height: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerBox(width: 28, height: 28),
                const SizedBox(width: 10),
                const ShimmerBox(width: 100, height: 18),
              ],
            ),
            const SizedBox(height: 24),
            const Center(
              child: ShimmerBox(width: 120, height: 120),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShimmerBox(width: 80, height: 16),
                const SizedBox(width: 24),
                const ShimmerBox(width: 80, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodLogTile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const ShimmerBox(width: 40, height: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(height: 14, width: 120),
                  const SizedBox(height: 8),
                  const ShimmerLine(height: 10, width: 80),
                ],
              ),
            ),
            const ShimmerBox(width: 60, height: 20),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Home Page Shimmer
// ═══════════════════════════════════════════════════════════════════

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            const ShimmerLine(height: 28, width: 220),
            const SizedBox(height: 4),
            const ShimmerLine(height: 16, width: 160),
            const SizedBox(height: 24),

            // BMI + Calorie cards
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBmiCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCalorieCard()),
                ],
              )
            else ...[
              _buildBmiCard(),
              const SizedBox(height: 16),
              _buildCalorieCard(),
              const SizedBox(height: 16),
              _buildRemainingCard(),
            ],
            const SizedBox(height: 16),

            // Goal card
            _buildGoalCard(),
            const SizedBox(height: 16),

            // Action cards
            if (isWide)
              Row(
                children: [
                  Expanded(child: _buildActionCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActionCard()),
                ],
              )
            else ...[
              _buildActionCard(),
              const SizedBox(height: 16),
              _buildActionCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBmiCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerBox(width: 48, height: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerLine(height: 12, width: 60),
                      const SizedBox(height: 8),
                      const ShimmerLine(height: 24, width: 100),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const ShimmerLine(height: 10),
            const SizedBox(height: 12),
            const ShimmerLine(height: 14, width: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerBox(width: 48, height: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerLine(height: 12, width: 100),
                      const SizedBox(height: 8),
                      const ShimmerLine(height: 24, width: 130),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const ShimmerBox(width: 70, height: 24),
                const Spacer(),
                const ShimmerBox(width: 70, height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const ShimmerBox(width: 48, height: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(height: 12, width: 100),
                  const SizedBox(height: 6),
                  const ShimmerLine(height: 20, width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const ShimmerBox(width: 48, height: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(height: 12, width: 70),
                  const SizedBox(height: 6),
                  const ShimmerLine(height: 18, width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const ShimmerBox(width: 48, height: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(height: 16, width: 100),
                  const SizedBox(height: 4),
                  const ShimmerLine(height: 12, width: 140),
                ],
              ),
            ),
            const ShimmerBox(width: 32, height: 32),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Calorie Card Shimmer (for recommendation loading on home page)
// ═══════════════════════════════════════════════════════════════════

class CalorieCardShimmer extends StatelessWidget {
  const CalorieCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ShimmerBox(width: 48, height: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ShimmerLine(height: 12, width: 100),
                            const SizedBox(height: 8),
                            const ShimmerLine(height: 24, width: 130),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const ShimmerBox(width: 70, height: 24),
                      const Spacer(),
                      const ShimmerBox(width: 70, height: 24),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ShimmerLine(height: 10),
                  const SizedBox(height: 12),
                  const ShimmerLine(height: 12, width: 180),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const ShimmerBox(width: 48, height: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerLine(height: 12, width: 100),
                        const SizedBox(height: 6),
                        const ShimmerLine(height: 20, width: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Analytics Shimmer
// ═══════════════════════════════════════════════════════════════════

class AnalyticsShimmer extends StatelessWidget {
  const AnalyticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: isWide
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _buildWideLayout(),
                ),
              )
            : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildCalorieProgressCard(),
        const SizedBox(height: 16),
        _buildPieChartCard(),
        const SizedBox(height: 16),
        _buildBarChartCard(),
        const SizedBox(height: 16),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildCalorieProgressCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildPieChartCard()),
          ],
        ),
        const SizedBox(height: 16),
        _buildBarChartCard(),
        const SizedBox(height: 16),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildCalorieProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerBox(width: 28, height: 28),
                const SizedBox(width: 10),
                const ShimmerBox(width: 120, height: 18),
              ],
            ),
            const SizedBox(height: 24),
            const Center(
              child: ShimmerBox(width: 140, height: 140),
            ),
            const SizedBox(height: 16),
            const Center(
              child: ShimmerBox(width: 100, height: 20),
            ),
            const SizedBox(height: 8),
            const Center(
              child: ShimmerBox(width: 160, height: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerBox(width: 28, height: 28),
                const SizedBox(width: 10),
                const ShimmerBox(width: 140, height: 18),
              ],
            ),
            const SizedBox(height: 24),
            const Center(
              child: ShimmerBox(width: 120, height: 120),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShimmerBox(width: 80, height: 16),
                const SizedBox(width: 24),
                const ShimmerBox(width: 80, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerBox(width: 28, height: 28),
                const SizedBox(width: 10),
                const ShimmerBox(width: 130, height: 18),
              ],
            ),
            const SizedBox(height: 24),
            // Bar chart placeholder
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                5,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ShimmerLine(
                      height: [60.0, 90.0, 45.0, 75.0, 50.0][i],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                5,
                (_) => const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ShimmerLine(height: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerLine(height: 18, width: 120),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(),
                  _buildSummaryRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const ShimmerBox(width: 40, height: 40),
          const SizedBox(width: 14),
          const Expanded(
            child: ShimmerLine(height: 14, width: 100),
          ),
          const ShimmerBox(width: 60, height: 18),
        ],
      ),
    );
  }
}
