import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../logic/insights/insights_state.dart';

class MonthComparisonCard extends StatelessWidget {
  final InsightsLoaded state;

  const MonthComparisonCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
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
                alpha: 0.1,
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
}
