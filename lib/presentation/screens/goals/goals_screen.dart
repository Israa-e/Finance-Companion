import 'package:finance_companion/presentation/screens/goals/widgets/add_goal_sheet.dart';
import 'package:finance_companion/presentation/screens/goals/widgets/goal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../logic/goal/goal_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/custom_button.dart';

import 'package:finance_companion/l10n/app_localizations.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.goals, style: AppTextStyles.h2),
                  GestureDetector(
                    onTap: () => _showAddGoal(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Expanded(
                child: BlocBuilder<GoalCubit, GoalState>(
                  builder: (context, state) {
                    if (state is GoalLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is GoalError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.expense,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (state is! GoalLoaded || state.goals.isEmpty) {
                      return EmptyStateWidget(
                        title: l10n.noGoalsTitle,
                        subtitle: l10n.noGoalsSubtitle,
                        icon: Iconsax.chart,
                        action: CustomButton(
                          label: l10n.addGoal,
                          onTap: () => _showAddGoal(context),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => context.read<GoalCubit>().loadGoals(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.goals.length,
                        separatorBuilder: (_, __) => const Gap(12),
                        itemBuilder: (context, i) => GoalCard(
                          goal: state.goals[i],
                          onDeleteConfirmed: () => context
                              .read<GoalCubit>()
                              .deleteGoal(state.goals[i].id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGoal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<GoalCubit>(),
        child: const AddGoalSheet(),
      ),
    );
  }
}
