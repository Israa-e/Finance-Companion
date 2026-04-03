import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/insights/insights_cubit.dart';
import '../../../logic/insights/insights_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../shared/widgets/empty_state_widget.dart';

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

                if (state is! InsightsLoaded) {
                  return const SizedBox.shrink();
                }

                // No transactions at all
                if (state.expensesByCategory.isEmpty &&
                    state.thisMonthExpense == 0 &&
                    state.lastMonthExpense == 0) {
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16),
                    Text('Insights', style: AppTextStyles.h2),
                    const Gap(20),
                    _buildTopCategory(state),
                    const Gap(16),
                    _buildMonthComparison(context, state),
                    if (state.expensesByCategory.isNotEmpty) ...[
                      const Gap(16),
                      _buildPieChart(context, state),
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

  Widget _buildTopCategory(InsightsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.chart_2, color: Colors.white, size: 36),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Spending',
                  style: AppTextStyles.label.copyWith(color: Colors.white70),
                ),
                Text(
                  state.topCategory.isEmpty ? 'No data' : state.topCategory,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyFormatter.format(state.topCategoryAmount),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthComparison(BuildContext context, InsightsLoaded state) {
    final isUp = state.isSpendingUp;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Month', style: AppTextStyles.label),
                Text(
                  CurrencyFormatter.format(state.thisMonthExpense),
                  style: AppTextStyles.amountSmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isUp ? AppColors.expense : AppColors.income).withValues(
                alpha: .1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? Iconsax.arrow_up : Iconsax.arrow_down,
                  size: 14,
                  color: isUp ? AppColors.expense : AppColors.income,
                ),
                const Gap(4),
                Text(
                  CurrencyFormatter.formatCompact(state.monthlyChange.abs()),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isUp ? AppColors.expense : AppColors.income,
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Last Month', style: AppTextStyles.label),
                Text(
                  CurrencyFormatter.format(state.lastMonthExpense),
                  style: AppTextStyles.amountSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, InsightsLoaded state) {
    final entries = state.expensesByCategory.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);
    // Guard: wrap color index so we never go out of bounds regardless
    // of how many categories the user creates.
    final colorCount = AppColors.categoryColors.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by Category', style: AppTextStyles.h3),
          const Gap(20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: List.generate(entries.length, (i) {
                  final pct = entries[i].value / total * 100;
                  final color = AppColors.categoryColors[i % colorCount];
                  return PieChartSectionData(
                    color: color,
                    value: entries[i].value,
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const Gap(16),
          ...List.generate(
            entries.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.categoryColors[i % colorCount],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      entries[i].key,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(entries[i].value),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
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
