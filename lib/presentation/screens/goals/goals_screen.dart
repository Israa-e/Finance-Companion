import 'package:finance_companion/presentation/screens/goals/widgets/goal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                        title: 'No goals yet',
                        subtitle: 'Set a savings goal to track your progress',
                        icon: Iconsax.chart,
                        action: CustomButton(
                          label: 'Add Goal',
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
        child: const _AddGoalSheet(),
      ),
    );
  }
}

// ─── Add Goal Sheet ───────────────────────────────────────────────────────────

class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet();

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _emoji = '🎯';
  bool _isLoading = false;

  static const _emojis = [
    '🎯',
    '🏠',
    '✈️',
    '🚗',
    '💻',
    '📱',
    '🎓',
    '💍',
    '🏖️',
    '💰',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Wrap(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
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
                  // Title field with validator
                  CustomTextField(
                    label: 'Goal title',
                    controller: _titleController,
                    hint: 'e.g. New laptop',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter a title'
                        : null,
                  ),
                  const Gap(12),
                  // Amount field with validator
                  CustomTextField(
                    label: 'Target amount',
                    controller: _amountController,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter a target amount';
                      }
                      final parsed = double.tryParse(v);
                      if (parsed == null) return 'Enter a valid number';
                      if (parsed <= 0)
                        return 'Amount must be greater than zero';
                      return null;
                    },
                  ),
                  const Gap(12),
                  // Date picker row
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Iconsax.calendar,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'End Date: ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                      style: AppTextStyles.body,
                    ),
                    onTap: _pickDate,
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _emojis.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => setState(() => _emoji = _emojis[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Safe parse — validator already confirmed this is a valid double
    final amount = double.parse(_amountController.text);

    setState(() => _isLoading = true);
    await context.read<GoalCubit>().addGoal(
      title: _titleController.text.trim(),
      targetAmount: amount,
      endDate: _endDate,
      emoji: _emoji,
    );
    if (mounted) Navigator.pop(context);
  }
}
