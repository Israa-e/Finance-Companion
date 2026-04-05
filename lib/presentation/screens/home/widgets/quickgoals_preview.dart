import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../logic/goal/goal_cubit.dart';
import '../../../../logic/goal/goal_state.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/goal_model.dart';
import 'package:finance_companion/l10n/app_localizations.dart';

class QuickGoalsPreview extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const QuickGoalsPreview({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalCubit, GoalState>(
      builder: (context, state) {
        if (state is! GoalLoaded || state.activeGoals.isEmpty) {
          return const SizedBox.shrink();
        }

        final goals = state.activeGoals.take(3).toList();
        final totalSaved = state.activeGoals.fold(
          0.0,
          (s, g) => s + g.savedAmount,
        );
        final totalTarget = state.activeGoals.fold(
          0.0,
          (s, g) => s + g.targetAmount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.savingsGoals, style: AppTextStyles.h3),
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    AppLocalizations.of(context)!.seeAll,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Builder(
              builder: (context) {
                final authState = context.watch<AuthCubit>().state;
                final formatter = authState is AuthAuthenticated
                    ? authState.formatter
                    : const CurrencyFormatter();
                return Text(
                  AppLocalizations.of(context)!.savedOfTotal(
                    formatter.formatCompact(totalSaved),
                    formatter.formatCompact(totalTarget),
                  ),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
            const Gap(8),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: goals.length,
                separatorBuilder: (_, __) => const Gap(16),
                itemBuilder: (_, i) => _GoalChip(goal: goals[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GoalChip extends StatelessWidget {
  final GoalModel goal;
  const _GoalChip({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercent;
    final color = _colorForProgress(progress);

    final authState = context.watch<AuthCubit>().state;
    final formatter = authState is AuthAuthenticated
        ? authState.formatter
        : const CurrencyFormatter();

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Text(goal.emoji ?? '🎯', style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            goal.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const Gap(8),
          Text(
            '${formatter.formatCompact(goal.savedAmount)}'
            ' / ${formatter.formatCompact(goal.targetAmount)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForProgress(double p) {
    if (p >= 0.8) return AppColors.income;
    if (p >= 0.4) return AppColors.savings;
    return AppColors.primary;
  }
}
