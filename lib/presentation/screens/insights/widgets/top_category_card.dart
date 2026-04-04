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

class TopCategoryCard extends StatelessWidget {
  final InsightsLoaded state;
  const TopCategoryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Iconsax.chart_21,
              color: Colors.white,
              size: 26,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Spending',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 0.5,
                  ),
                ),
                const Gap(4),
                Text(
                  state.topCategory.isEmpty ? 'No data' : state.topCategory,
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Builder(
                  builder: (context) {
                    final authState = context.watch<AuthCubit>().state;
                    final formatter = authState is AuthAuthenticated
                        ? authState.formatter
                        : const CurrencyFormatter();
                    return Text(
                      formatter.format(state.topCategoryAmount),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (state.topCategoryAmount > 0 && _totalExpenses > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${(_pct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  double get _totalExpenses =>
      state.expensesByCategory.values.fold(0.0, (a, b) => a + b);

  double get _pct => _totalExpenses == 0
      ? 0
      : (state.topCategoryAmount / _totalExpenses).clamp(0.0, 1.0);
}