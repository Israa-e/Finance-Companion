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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<InsightsCubit>().loadInsights(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
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

                if (state is! InsightsLoaded) return const SizedBox.shrink();

                final isEmpty = state.expensesByCategory.isEmpty &&
                    state.thisMonthExpense == 0 &&
                    state.lastMonthExpense == 0;

                if (isEmpty) {
                  return const SizedBox(
                    height: 400,
                    child: EmptyStateWidget(
                      title: 'No data yet',
                      subtitle: 'Add some transactions to start seeing insights',
                      icon: Iconsax.chart,
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16),
                    Text('Insights', style: AppTextStyles.h2),
                    const Gap(20),

                    // ── Top spending category ──────────────────────────
                    TopCategoryCard(state: state),
                    const Gap(16),

                    // ── Month vs last month ────────────────────────────
                    MonthComparisonCard(state: state),
                    const Gap(16),

                    // ── Frequent transaction type ──────────────────────
                    if (state.mostFrequentCategory.isNotEmpty) ...[
                      FrequentCategoryCard(state: state),
                      const Gap(16),
                    ],

                    // ── Monthly trend (last 6 months) ──────────────────
                    if (state.monthlyTrend.isNotEmpty) ...[
                      MonthlyTrendChart(state: state),
                      const Gap(16),
                    ],

                    // ── Pie chart by category ──────────────────────────
                    if (state.expensesByCategory.isNotEmpty) ...[
                      CategoryPieChart(state: state),
                    ],

                    const Gap(24),
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

