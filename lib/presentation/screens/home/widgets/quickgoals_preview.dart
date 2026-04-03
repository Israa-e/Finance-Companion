import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../logic/goal/goal_cubit.dart';
import '../../../../logic/goal/goal_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/goal_model.dart';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Savings Goals', style: AppTextStyles.h3),
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
            Text(
              '${CurrencyFormatter.formatCompact(totalSaved)} saved'
              ' of ${CurrencyFormatter.formatCompact(totalTarget)} total',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Gap(16),
            // 120px gives the chip content (≈96px) + padding (24px) = 120px
            // with 0px to spare — safe on all densities.
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: goals.length,
                separatorBuilder: (_, _) => const Gap(16),
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

    return Container(
      width: 160,
      // Padding reduced from 14→12 so total vertical content fits in 120px.
      // Content budget: 12 top + 29(emoji row) + 6 + 17(title) + 6 +
      //                 5(bar) + 5 + 16(amount) + 12 bottom = 108px ✓
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
        // Use start + explicit gaps instead of spaceBetween.
        // spaceBetween distributes leftover space unpredictably when
        // text height varies across font scales / screen densities.
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // ── Emoji row ──────────────────────────────────────────────
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
          // ── Goal title ─────────────────────────────────────────────
          Text(
            goal.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          // ── Progress bar ───────────────────────────────────────────
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
          // ── Saved / target amounts ─────────────────────────────────
          Text(
            '${CurrencyFormatter.formatCompact(goal.savedAmount)}'
            ' / ${CurrencyFormatter.formatCompact(goal.targetAmount)}',
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
