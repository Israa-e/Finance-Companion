import 'package:finance_companion/core/theme/app_colors.dart';
import 'package:finance_companion/core/theme/app_text_styles.dart';
import 'package:finance_companion/core/utils/currency_formatter.dart';
import 'package:finance_companion/data/models/goal_model.dart';
import 'package:finance_companion/logic/goal/goal_cubit.dart';
import 'package:finance_companion/logic/goal/goal_state.dart';
import 'package:finance_companion/logic/transaction/transaction_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:finance_companion/presentation/shared/widgets/custom_text_field.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercent;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.emoji ?? '🎯', style: const TextStyle(fontSize: 28)),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${goal.daysRemaining} days left',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.add_circle, color: AppColors.primary),
                onPressed: () => _showAddSavings(context, goal),
              ),
              IconButton(
                icon: const Icon(
                  Iconsax.trash,
                  color: AppColors.expense,
                  size: 18,
                ),
                onPressed: () => context.read<GoalCubit>().deleteGoal(goal.id),
              ),
            ],
          ),
          const Gap(14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(goal.savedAmount),
                style: AppTextStyles.amountSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                CurrencyFormatter.format(goal.targetAmount),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const Gap(6),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% achieved',
            style: AppTextStyles.caption,
          ),
          const Gap(4),
          Text(
            'Remaining: ${CurrencyFormatter.format(goal.remainingAmount)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  void _showAddSavings(BuildContext context, GoalModel goal) {
    final txState = context.read<TransactionCubit>().state;
    final goalState = context.read<GoalCubit>().state;
    final lockedAmount = goalState is GoalLoaded
        ? goalState.goals.fold(0.0, (sum, goal) => sum + goal.savedAmount)
        : 0.0;
    final totalBalance = txState is TransactionLoaded ? txState.balance : 0.0;
    final availableBalance = (totalBalance - lockedAmount).clamp(
      0.0,
      double.infinity,
    );
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Wrap(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textHint,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Text('Add to Savings', style: AppTextStyles.h3),
                    const Gap(8),
                    Text(
                      'Available: ${CurrencyFormatter.format(availableBalance)}',
                      style: AppTextStyles.caption,
                    ),
                    const Gap(16),
                    CustomTextField(
                      label: 'Amount',
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      hint: 'Amount',
                    ),
                    const Gap(18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final amount = double.tryParse(controller.text);
                              if (amount == null || amount <= 0) return;
                              if (amount > availableBalance) {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Not enough available balance to allocate.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (amount > goal.remainingAmount) {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Goal only needs ${CurrencyFormatter.format(goal.remainingAmount)} more.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              context.read<GoalCubit>().addToSavings(
                                goal.id,
                                amount,
                                availableBalance: availableBalance,
                              );
                              Navigator.pop(sheetContext);
                            },
                            child: const Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
