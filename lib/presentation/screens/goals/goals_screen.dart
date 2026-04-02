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
import '../../shared/widgets/custom_text_field.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Text('Goals', style: AppTextStyles.h2),
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
                    if (state is! GoalLoaded || state.goals.isEmpty) {
                      return EmptyStateWidget(
                        title: 'No goals yet',
                        subtitle: 'Set a savings goal to track your progress',
                        icon: Iconsax.chart,
                        action: CustomButton(
                          label: 'Add Goal',
                          onTap: () => _showAddGoal(context),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: state.goals.length,
                      separatorBuilder: (_, _) => const Gap(12),
                      itemBuilder: (context, i) =>
                          GoalCard(goal: state.goals[i]),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GoalCubit>(),
        child: const _AddGoalSheet(),
      ),
    );
  }
}

class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet();

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _emoji = '🎯';
  bool _isLoading = false;

  final _emojis = ['🎯', '🏠', '✈️', '🚗', '💻', '📱', '🎓', '💍', '🏖️', '💰'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
            Text('New Goal', style: AppTextStyles.h3),
            const Gap(16),
            _buildEmojiPicker(),
            const Gap(16),
            CustomTextField(
              label: 'Goal title',
              controller: _titleController,
              hint: 'Goal title',
            ),
            const Gap(12),
            CustomTextField(
              label: 'Target amount',
              controller: _amountController,
              hint: 'Target amount',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const Gap(12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Iconsax.calendar, color: AppColors.primary),
              title: Text(
                'End Date: ${_endDate.day}/${_endDate.month}/${_endDate.year}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) setState(() => _endDate = picked);
              },
            ),
            const Gap(16),
            CustomButton(
              label: 'Create Goal',
              isLoading: _isLoading,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _emojis.length,
        separatorBuilder: (_, _) => const Gap(8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => setState(() => _emoji = _emojis[i]),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _emoji == _emojis[i]
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: _emoji == _emojis[i]
                  ? Border.all(color: AppColors.primary)
                  : null,
            ),
            child: Center(
              child: Text(_emojis[i], style: const TextStyle(fontSize: 22)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await context.read<GoalCubit>().addGoal(
      title: _titleController.text.trim(),
      targetAmount: double.parse(_amountController.text),
      endDate: _endDate,
      emoji: _emoji,
    );
    if (mounted) Navigator.pop(context);
  }
}
