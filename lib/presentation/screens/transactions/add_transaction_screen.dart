import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../logic/goal/goal_state.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/transaction/transaction_state.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/transaction_category_dropdown.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded && state.submitSuccess) {
          Navigator.pop(context);
        }
        if (state is TransactionLoaded && state.formErrorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.formErrorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state is! TransactionLoaded) return const Scaffold();
        final cubit = context.read<TransactionCubit>();

        // We also need GoalCubit to calculate available balance for validation
        final goalState = context.watch<GoalCubit>().state;
        final lockedAmount = goalState is GoalLoaded ? goalState.totalLocked : 0.0;
        final availableToSpend = state.balance - lockedAmount;

        return Scaffold(
          appBar: AppBar(
            title: Text('Add Transaction', style: AppTextStyles.h3),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TransactionTypeToggle(),
                  const Gap(24),
                  CustomTextField(
                    label: 'Amount',
                    controller: _amountController,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      if (val != null) cubit.updateFormAmount(val);
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter amount';
                      final val = double.tryParse(v);
                      if (val == null || val <= 0) return 'Invalid amount';
                      
                      if (state.formType == TransactionType.expense && val > availableToSpend) {
                        return 'Only ${CurrencyFormatter.format(availableToSpend)} available (locked in goals)';
                      }
                      return null;
                    },
                  ),
                  const Gap(20),
                  const TransactionCategoryDropdown(),
                  const Gap(20),
                  CustomTextField(
                    label: 'Title',
                    controller: _titleController,
                    hint: 'e.g. Grocery Shopping',
                    onChanged: (v) => cubit.updateFormTitle(v),
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter title' : null,
                  ),
                  const Gap(20),
                  _buildDatePicker(context, cubit, state.formDate),
                  const Gap(20),
                  CustomTextField(
                    label: 'Note (Optional)',
                    controller: _noteController,
                    hint: 'Add some details...',
                    onChanged: (v) => cubit.updateFormNote(v),
                    maxLines: 3,
                  ),
                  const Gap(32),
                  CustomButton(
                    label: 'Save Transaction',
                    isLoading: state.isSubmitting,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        cubit.submitTransactionForm();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(BuildContext context, TransactionCubit cubit, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        const Gap(8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) cubit.updateFormDate(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar, size: 20, color: AppColors.primary),
                const Gap(12),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
