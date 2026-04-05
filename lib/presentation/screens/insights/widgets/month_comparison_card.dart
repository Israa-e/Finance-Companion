import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../logic/insights/insights_state.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import 'package:finance_companion/l10n/app_localizations.dart';

class MonthComparisonCard extends StatelessWidget {
  final InsightsLoaded state;
  const MonthComparisonCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUp = state.isSpendingUp;
    final changeColor = isUp ? AppColors.expense : AppColors.income;
    // final changeLabel = isUp ? l10n.moreThanLastMonth('') : l10n.lessThanLastMonth('');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.monthlyComparison,
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _MonthBlock(
                  label: l10n.thisMonthLabel,
                  amount: state.thisMonthExpense,
                  isHighlighted: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  isUp ? Iconsax.arrow_up : Iconsax.arrow_down,
                  color: changeColor,
                  size: 20,
                ),
              ),
              Expanded(
                child: _MonthBlock(
                  label: l10n.lastMonthLabel,
                  amount: state.lastMonthExpense,
                  isHighlighted: false,
                ),
              ),
            ],
          ),
          const Gap(14),
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
                Builder(
                  builder: (context) {
                    final authState = context.watch<AuthCubit>().state;
                    final formatter = authState is AuthAuthenticated
                        ? authState.formatter
                        : const CurrencyFormatter();
                    final formattedAmount = formatter.format(state.monthlyChange.abs());
                    return Text(
                      isUp ? l10n.moreThanLastMonth(formattedAmount) : l10n.lessThanLastMonth(formattedAmount),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
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
    return Column(
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
        Builder(
          builder: (context) {
            final authState = context.watch<AuthCubit>().state;
            final formatter = authState is AuthAuthenticated
                ? authState.formatter
                : const CurrencyFormatter();
            return Text(
              formatter.format(amount),
              style: AppTextStyles.body.copyWith(
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            );
          },
        ),
      ],
    );
  }
}