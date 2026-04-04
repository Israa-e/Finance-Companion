// insights_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/insights/insights_cubit.dart';
import '../../../logic/insights/insights_state.dart';
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
          onRefresh: () => context.read<InsightsCubit>().loadInsights(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: BlocBuilder<InsightsCubit, InsightsState>(
              builder: (context, state) {
                // ── Loading ──────────────────────────────────────────
                if (state is InsightsLoading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // ── Error ────────────────────────────────────────────
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

                if (state is! InsightsLoaded) return const SizedBox.shrink();

                // ── Empty ────────────────────────────────────────────
                final isEmpty = state.expensesByCategory.isEmpty &&
                    state.thisMonthExpense == 0 &&
                    state.lastMonthExpense == 0;

                if (isEmpty) {
                  return const SizedBox(
                    height: 400,
                    child: EmptyStateWidget(
                      title: 'No data yet',
                      subtitle:
                          'Add some transactions to start seeing insights',
                      icon: Iconsax.chart,
                    ),
                  );
                }

                // ── Content ──────────────────────────────────────────
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16),
                    Text(
                      'Insights',
                      style: AppTextStyles.h2.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Gap(20),

                    // 1 ── Top spending category
                    if (state.topCategory.isNotEmpty) ...[
                      TopCategoryCard(state: state),
                      const Gap(16),
                    ],

                    // 2 ── Month comparison
                    MonthComparisonCard(state: state),
                    const Gap(16),

                    // 3 ── Most frequent category
                    if (state.mostFrequentCategory.isNotEmpty) ...[
                      FrequentCategoryCard(state: state),
                      const Gap(16),
                    ],

                    // 4 ── Monthly trend (last 6 months)
                    if (state.monthlyTrend.isNotEmpty) ...[
                      MonthlyTrendChart(state: state),
                      const Gap(16),
                    ],

                    // 5 ── Pie chart breakdown
                    if (state.expensesByCategory.isNotEmpty)
                      CategoryPieChart(state: state),
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