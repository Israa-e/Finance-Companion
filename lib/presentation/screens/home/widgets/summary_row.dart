import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../../../../logic/transaction/transaction_filter_cubit.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:finance_companion/l10n/app_localizations.dart';

class SummaryRow extends StatelessWidget {
  final bool isGlassy;
  const SummaryRow({super.key, this.isGlassy = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFilterCubit, TransactionFilterState>(
      builder: (context, state) {
        final income = state.totalIncome;
        final expense = state.totalExpense;

        return Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: AppLocalizations.of(context)!.income,
                amount: income,
                icon: Iconsax.arrow_down,
                color: AppColors.income,
                isGlassy: isGlassy,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _SummaryCard(
                label: AppLocalizations.of(context)!.expense,
                amount: expense,
                icon: Iconsax.arrow_up,
                color: AppColors.expense,
                isGlassy: isGlassy,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isGlassy;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isGlassy,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: ${amount.toStringAsFixed(2)}',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isGlassy 
              ? Colors.white.withValues(alpha: 0.12)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isGlassy 
              ? Border.all(color: Colors.white.withValues(alpha: 0.15))
              : null,
          boxShadow: isGlassy ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label, 
                    style: AppTextStyles.caption.copyWith(
                      color: isGlassy ? Colors.white.withValues(alpha: 0.65) : null,
                      fontSize: 10,
                    ),
                  ),
                  const Gap(2),
                  Builder(
                    builder: (context) {
                      final authState = context.watch<AuthCubit>().state;
                      final formatter = authState is AuthAuthenticated
                          ? authState.formatter
                          : const CurrencyFormatter();
                      return Text(
                        formatter.formatCompact(amount),
                        style: AppTextStyles.amountSmall.copyWith(
                          color: isGlassy ? Colors.white : null,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
