import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class RecentTransactions extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const RecentTransactions({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is! TransactionLoaded) return const SizedBox.shrink();

        final recent = state.transactions.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent', style: AppTextStyles.h3),
                if (state.transactions.isNotEmpty)
                  TextButton(
                    onPressed: onSeeAll,
                    child: Text(
                      'See all',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(8),
            if (recent.isEmpty)
              const EmptyStateWidget(
                title: 'No transactions yet',
                subtitle: 'Add your first transaction to get started',
                icon: Iconsax.receipt,
              )
            else
              ...recent.map((t) => _TransactionTile(transaction: t)),
          ],
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isIncome ? AppColors.income : AppColors.expense)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Iconsax.arrow_down : Iconsax.arrow_up,
              color: isIncome ? AppColors.income : AppColors.expense,
              size: 20,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(transaction.category, style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatSigned(
                  transaction.amount,
                  isExpense: !isIncome,
                ),
                style: AppTextStyles.amountSmall.copyWith(
                  color: isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
              Text(
                DateFormatter.formatShort(transaction.date),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
