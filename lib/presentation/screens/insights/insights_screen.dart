import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/insights/insights_cubit.dart';
import '../../../logic/insights/insights_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/widgets/empty_state_widget.dart';

import 'widgets/category_pie_chart.dart';
import 'widgets/frequent_category_card.dart';
import 'widgets/month_comparison_card.dart';
import 'widgets/monthly_trend_chart.dart';
import 'widgets/top_category_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            final state = context.read<InsightsCubit>().state;
            final period = state is InsightsLoaded
                ? state.activePeriod
                : InsightsPeriod.allTime;
            return context.read<InsightsCubit>().loadInsights(period: period);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: BlocBuilder<InsightsCubit, InsightsState>(
              builder: (context, state) {
                if (state is InsightsLoading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is InsightsError) {
                  return SizedBox(
                    height: 400,
                    child: EmptyStateWidget(
                      title: 'Could not load insights',
                      subtitle: state.message,
                      icon: Iconsax.warning_2,
                    ),
                  );
                }

                final activePeriod = state is InsightsLoaded
                    ? state.activePeriod
                    : InsightsPeriod.allTime;

                if (state is! InsightsLoaded) return const SizedBox.shrink();

                final isEmpty = state.expensesByCategory.isEmpty &&
                    state.thisMonthExpense == 0 &&
                    state.lastMonthExpense == 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Insights',
                          style: AppTextStyles.h2.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),

                    // FIX: Period selector — answers "this month vs all time"
                    _PeriodSelector(activePeriod: activePeriod),
                    const Gap(20),

                    if (isEmpty)
                      const SizedBox(
                        height: 300,
                        child: EmptyStateWidget(
                          title: 'No data for this period',
                          subtitle:
                              'Add some transactions to start seeing insights',
                          icon: Iconsax.chart,
                        ),
                      )
                    else ...[
                      if (state.topCategory.isNotEmpty) ...[
                        TopCategoryCard(state: state),
                        const Gap(16),
                      ],
                      MonthComparisonCard(state: state),
                      const Gap(16),
                      if (state.mostFrequentCategory.isNotEmpty) ...[
                        FrequentCategoryCard(state: state),
                        const Gap(16),
                      ],
                      if (state.monthlyTrend.isNotEmpty) ...[
                        MonthlyTrendChart(state: state),
                        const Gap(16),
                      ],
                      if (state.expensesByCategory.isNotEmpty)
                        CategoryPieChart(state: state),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Period selector chip row ──────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final InsightsPeriod activePeriod;

  const _PeriodSelector({required this.activePeriod});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: InsightsPeriod.values.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (context, i) {
          final period = InsightsPeriod.values[i];
          final isActive = period == activePeriod;
          return GestureDetector(
            onTap: () =>
                context.read<InsightsCubit>().changePeriod(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                period.label,
                style: AppTextStyles.caption.copyWith(
                  color: isActive
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}