import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../logic/goal/goal_cubit.dart';
import '../../../../logic/goal/goal_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/date_picker_sheet.dart';

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

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
    return BlocConsumer<GoalCubit, GoalState>(
      listener: (context, state) {
        if (state is GoalLoaded && state.submitSuccess) {
          Navigator.pop(context);
        }
        if (state is GoalLoaded && state.formErrorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.formErrorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state is! GoalLoaded) return const SizedBox.shrink();
        final cubit = context.read<GoalCubit>();

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
                      _buildEmojiPicker(context, cubit, state.formEmoji),
                      const Gap(16),
                      CustomTextField(
                        label: 'Goal title',
                        controller: _titleController,
                        hint: 'e.g. New laptop',
                        onChanged: (v) => cubit.updateFormTitle(v),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please enter a title'
                            : null,
                      ),
                      const Gap(12),
                      CustomTextField(
                        label: 'Target amount',
                        controller: _amountController,
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null) cubit.updateFormAmount(parsed);
                        },
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
                          if (parsed <= 0) {
                            return 'Amount must be greater than zero';
                          }
                          return null;
                        },
                      ),
                      const Gap(12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Iconsax.calendar,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          state.formEndDate != null
                              ? 'End Date: ${state.formEndDate!.day}/${state.formEndDate!.month}/${state.formEndDate!.year}'
                              : 'End Date: Select Date',
                          style: AppTextStyles.body,
                        ),
                        onTap: () => _pickDate(context, cubit,
                            state.formEndDate ?? DateTime.now()),
                      ),
                      const Gap(16),
                      CustomButton(
                        label: 'Create Goal',
                        isLoading: state.isSubmitting,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            cubit.submitGoalForm();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmojiPicker(
      BuildContext context, GoalCubit cubit, String activeEmoji) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _emojis.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => cubit.updateFormEmoji(_emojis[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activeEmoji == _emojis[i]
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: activeEmoji == _emojis[i]
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

  void _pickDate(
      BuildContext context, GoalCubit cubit, DateTime currentDate) {
    final now = DateTime.now();
    final initial = currentDate.isBefore(now) ? now : currentDate;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DatePickerSheet(
        initialDate: initial,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365 * 5)),
        onDateSelected: (newDate) => cubit.updateFormDate(newDate),
      ),
    );
  }
}
