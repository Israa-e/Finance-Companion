import 'package:finance_companion/presentation/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import 'package:gap/gap.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final accent = isIncome ? AppColors.income : AppColors.expense;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.expense,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Iconsax.trash, color: Colors.white, size: 16),
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete transaction?'),
            content: Text('Remove "${transaction.title}" permanently?'),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: CustomButton(
                      label: 'Delete',
                      color: AppColors.expense,
                      onTap: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Semantics(
        label: 'Transaction: ${transaction.title}',
        value: '${transaction.category}, ${transaction.amount}',
        hint: 'Swipe left to delete, tap edit icon to modify',
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _iconFor(transaction.category),
                  color: accent,
                  size: 22,
                ),
              ),
              const Gap(14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Gap(4),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        transaction.category,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Amount + Edit
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Builder(
                    builder: (context) {
                      final authState = context.watch<AuthCubit>().state;
                      final formatter = authState is AuthAuthenticated
                          ? authState.formatter
                          : const CurrencyFormatter();
                      return Text(
                        formatter.formatSigned(
                          transaction.amount,
                          isExpense: !isIncome,
                        ),
                        style: AppTextStyles.h3.copyWith(
                          color: isIncome ? AppColors.income : AppColors.expense,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const Gap(8),
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Iconsax.edit_2,
                        size: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Maps AppConstants category names → icons.
  /// Must match AppConstants.expenseCategories & AppConstants.incomeCategories
  IconData _iconFor(String category) {
    switch (category.toLowerCase()) {
      // ── Expense categories ──────────────────────────────────────────────
      case 'food & drinks':
        return Iconsax.coffee;
      case 'shopping':
        return Iconsax.bag;
      case 'transport':
        return Iconsax.car;
      case 'housing':
        return Iconsax.home;
      case 'entertainment':
        return Iconsax.music;
      case 'health':
        return Iconsax.health;
      case 'travel':
        return Iconsax.airplane;
      case 'education':
        return Iconsax.book;
      // ── Income categories ───────────────────────────────────────────────
      case 'salary':
        return Iconsax.money;
      case 'freelance':
        return Iconsax.briefcase;
      case 'investment':
        return Iconsax.chart;
      case 'gift':
        return Iconsax.gift;
      // ── Fallback ────────────────────────────────────────────────────────
      default:
        return Iconsax.wallet;
    }
  }
}
