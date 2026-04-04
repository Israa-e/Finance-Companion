// month_comparison_card.dart
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
    final changeColor = isUp ? AppColors.expense : AppColors.income;
    final changeLabel = isUp ? 'More than last month' : 'Less than last month';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ────────────────────────────────────────────────────
          Text(
            'Monthly Comparison',
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Gap(16),
          // ── Two columns ──────────────────────────────────────────────
          Row(
            children: [
              // This month
              Expanded(
                child: _MonthBlock(
                  label: 'This Month',
                  amount: state.thisMonthExpense,
                  isHighlighted: true,
                ),
              ),
              // Arrow in the middle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  isUp ? Iconsax.arrow_up : Iconsax.arrow_down,
                  color: changeColor,
                  size: 20,
                ),
              ),
              // Last month
              Expanded(
                child: _MonthBlock(
                  label: 'Last Month',
                  amount: state.lastMonthExpense,
                  isHighlighted: false,
                ),
              ),
            ],
          ),
          const Gap(14),
          // ── Change summary banner ─────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: changeColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUp ? Iconsax.arrow_up_3 : Iconsax.arrow_down_2,
                  color: changeColor,
                  size: 16,
                ),
                const Gap(8),
                Text(
                  '${CurrencyFormatter.format(state.monthlyChange.abs())}  $changeLabel',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBlock extends StatelessWidget {
  final String label;
  final double amount;
  final bool isHighlighted;

  const _MonthBlock({
    required this.label,
    required this.amount,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primary.withValues(alpha: 0.08)
            : Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
          const Gap(4),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTextStyles.amountSmall.copyWith(
              color: isHighlighted
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}