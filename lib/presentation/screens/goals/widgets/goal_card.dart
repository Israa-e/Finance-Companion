import 'package:finance_companion/l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';
import 'package:finance_companion/core/theme/app_colors.dart';
import 'package:finance_companion/core/theme/app_text_styles.dart';
import 'package:finance_companion/core/utils/currency_formatter.dart';
import 'package:finance_companion/data/models/goal_model.dart';
import 'package:finance_companion/logic/goal/goal_cubit.dart';
import 'package:finance_companion/logic/goal/goal_state.dart';
import 'package:finance_companion/logic/transaction/transaction_filter_cubit.dart';
import 'package:finance_companion/presentation/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import 'package:finance_companion/presentation/shared/widgets/custom_text_field.dart';

class GoalCard extends StatefulWidget {
  final GoalModel goal;
  final VoidCallback onDeleteConfirmed;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onDeleteConfirmed,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  late ConfettiController _confettiController;
  late double _lastProgress;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _lastProgress = widget.goal.progressPercent;
  }

  @override
  void didUpdateWidget(GoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentProgress = widget.goal.progressPercent;

    // Trigger celebration if crossing 50% or 100%
    if ((_lastProgress < 0.5 && currentProgress >= 0.5) ||
        (_lastProgress < 1.0 && currentProgress >= 1.0)) {
      _confettiController.play();
      HapticFeedback.heavyImpact();
    }
    _lastProgress = currentProgress;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthCubit>().state;
    final formatter = authState is AuthAuthenticated
        ? authState.formatter
        : const CurrencyFormatter();

    final progress = widget.goal.progressPercent;
    return Stack(
      children: [
        Semantics(
          label: 'Goal: ${widget.goal.title}',
          value: '${(progress * 100).toStringAsFixed(0)} percent complete',
          hint:
              widget.goal.isCompleted ? l10n.goalAchieved : l10n.addSavingsHint,
          child: Container(
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
                    if (widget.goal.isCompleted)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.2),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) => Transform.scale(
                          scale: value,
                          child: Text(widget.goal.emoji ?? '🎯',
                              style: const TextStyle(fontSize: 28)),
                        ),
                      )
                    else
                      Text(widget.goal.emoji ?? '🎯',
                          style: const TextStyle(fontSize: 28)),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.goal.title,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.goal.isCompleted
                                ? '🎉 ${l10n.completed}!'
                                : l10n.daysLeft(widget.goal.daysRemaining),
                            style: AppTextStyles.caption.copyWith(
                              color: widget.goal.isCompleted
                                  ? AppColors.income
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.goal.isCompleted)
                      IconButton(
                        icon: const Icon(
                          Iconsax.add_circle,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            _showAddSavings(context, widget.goal, formatter),
                      ),
                    IconButton(
                      icon: const Icon(
                        Iconsax.trash,
                        color: AppColors.expense,
                        size: 18,
                      ),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
                const Gap(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatter.format(widget.goal.savedAmount),
                      style: AppTextStyles.amountSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      formatter.format(widget.goal.targetAmount),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const Gap(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0, end: progress),
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.goal.isCompleted
                              ? AppColors.income
                              : AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
                const Gap(6),
                Text(
                  l10n.achieved((progress * 100).toStringAsFixed(1)),
                  style: AppTextStyles.caption,
                ),
                if (!widget.goal.isCompleted)
                  Text(
                    l10n.remaining(
                        formatter.format(widget.goal.remainingAmount)),
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.income,
              Colors.orange,
              Colors.pink,
            ],
            numberOfParticles: 20,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteGoal),
        content: Text(l10n.deleteGoalConfirm(widget.goal.title)),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
              ),
              const Gap(8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expense,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onDeleteConfirmed();
                  },
                  child: Text(l10n.delete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSavings(
    BuildContext context,
    GoalModel goal,
    CurrencyFormatter formatter,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final txState = context.read<TransactionFilterCubit>().state;
    final goalState = context.read<GoalCubit>().state;
    final lockedAmount = goalState is GoalLoaded
        ? goalState.goals.fold(0.0, (sum, g) => sum + g.savedAmount)
        : 0.0;
    final totalBalance = txState.balance;
    final availableBalance = (totalBalance - lockedAmount).clamp(
      0.0,
      double.infinity,
    );
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(sheetContext).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                Text(l10n.addToSavings, style: AppTextStyles.h3),
                const Gap(4),
                Text(
                  '${l10n.available}: ${formatter.format(availableBalance)}',
                  style: AppTextStyles.caption,
                ),
                const Gap(16),
                CustomTextField(
                  label: l10n.amount,
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  hint: '0.00',
                ),
                const Gap(18),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onTap: () => Navigator.pop(sheetContext),
                        color: Colors.grey,
                        label: l10n.cancel,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: CustomButton(
                        label: l10n.add,
                        onTap: () {
                          final amount =
                              double.tryParse(controller.text) ?? 0.0;
                          context.read<GoalCubit>().addToSavings(
                                goal.id,
                                amount,
                                availableBalance: availableBalance,
                              );
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
