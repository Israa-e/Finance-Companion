import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, txState) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final balance = txState is TransactionLoaded ? txState.balance : 0.0;
            final isLoading = txState is TransactionLoading;
            final userName = authState is AuthAuthenticated
                ? authState.user.name.split(' ').first
                : '';

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting row
                  if (userName.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.waving_hand_rounded,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Hi, $userName',
                          style: AppTextStyles.label
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const Gap(8),
                  ],
                  Text('Total Balance',
                      style: AppTextStyles.label
                          .copyWith(color: Colors.white70)),
                  const Gap(8),
                  isLoading
                      ? const SizedBox(
                          height: 40,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          CurrencyFormatter.format(balance),
                          style: AppTextStyles.amount
                              .copyWith(color: Colors.white),
                        ),
                  const Gap(16),
                  // Divider
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const Gap(16),
                  // Income / Expense mini row
                  if (txState is TransactionLoaded)
                    Row(
                      children: [
                        _MiniStat(
                          icon: Icons.arrow_downward_rounded,
                          label: 'Income',
                          value: CurrencyFormatter.formatCompact(
                              txState.totalIncome),
                          color: const Color(0xFF2DCE89),
                        ),
                        const SizedBox(width: 20),
                        _MiniStat(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Expenses',
                          value: CurrencyFormatter.formatCompact(
                              txState.totalExpense),
                          color: const Color(0xFFFF5B5B),
                        ),
                        if (txState.initialBalance > 0) ...[
                          const SizedBox(width: 20),
                          _MiniStat(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Starting',
                            value: CurrencyFormatter.formatCompact(
                                txState.initialBalance),
                            color: Colors.white54,
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 13),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}