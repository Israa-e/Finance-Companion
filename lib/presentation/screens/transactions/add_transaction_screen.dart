import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../logic/goal/goal_state.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/transaction/transaction_state.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/transaction_category_dropdown.dart';
import '../../shared/widgets/date_picker_sheet.dart';

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
      listenWhen: (previous, current) {
        // Only fire listener when submitSuccess flips true, or error message changes
        if (current is TransactionLoaded && previous is TransactionLoaded) {
          return (current.submitSuccess && !previous.submitSuccess) ||
              current.formErrorMessage != previous.formErrorMessage;
        }
        return false;
      },
      listener: (context, state) {
        if (state is TransactionLoaded && state.submitSuccess) {
          if (mounted) Navigator.pop(context);
          return;
        }
        if (state is TransactionLoaded && state.formErrorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.formErrorMessage!),
                backgroundColor: AppColors.expense,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
        }
      },
      builder: (context, state) {
        if (state is! TransactionLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final cubit = context.read<TransactionCubit>();

        final goalState = context.watch<GoalCubit>().state;
        final lockedAmount =
            goalState is GoalLoaded ? goalState.totalLocked : 0.0;
        // state.balance = initialBalance + income - expense (already correct)
        final availableToSpend =
            (state.balance - lockedAmount).clamp(0.0, double.infinity);

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
                  // ── Type toggle ─────────────────────────────────────
                  const TransactionTypeToggle(),
                  const Gap(24),

                  // ── Amount ──────────────────────────────────────────
                  Semantics(
                    label: 'Amount input field',
                    hint: 'Enter the transaction amount',
                    child: CustomTextField(
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
                        
                        final authState = context.read<AuthCubit>().state;
                        final formatter = authState is AuthAuthenticated 
                            ? authState.formatter 
                            : const CurrencyFormatter();
                            
                        if (state.formType == TransactionType.expense &&
                            val > availableToSpend) {
                          return 'Only ${formatter.format(availableToSpend)} available';
                        }
                        return null;
                      },
                    ),
                  ),
                  BlocBuilder<TransactionCubit, TransactionState>(
                    builder: (context, state) {
                      if (state is! TransactionLoaded) return const SizedBox.shrink();
                      if (state.formType != TransactionType.expense) return const SizedBox.shrink();

                      final goalState = context.watch<GoalCubit>().state;
                      final lockedAmount =
                          goalState is GoalLoaded ? goalState.totalLocked : 0.0;
                      final availableToSpend =
                          (state.balance - lockedAmount).clamp(0.0, double.infinity);

                      final authState = context.watch<AuthCubit>().state;
                      final formatter = authState is AuthAuthenticated 
                          ? authState.formatter 
                          : const CurrencyFormatter();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 13,
                                  color: availableToSpend < 50
                                      ? AppColors.expense
                                      : AppColors.textSecondary,
                                ),
                                const Gap(5),
                                Text(
                                  'Available to spend: ${formatter.formatCompact(availableToSpend)}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: availableToSpend < 50
                                        ? AppColors.expense
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(12),
                          _buildQuickAmounts(context, cubit),
                        ],
                      );
                    },
                  ),
                  const Gap(14),

                  // ── Category ────────────────────────────────────────
                  const TransactionCategoryDropdown(),
                  const Gap(20),

                  // ── Title ───────────────────────────────────────────
                  CustomTextField(
                    label: 'Title',
                    controller: _titleController,
                    hint: 'e.g. Grocery Shopping',
                    onChanged: (v) => cubit.updateFormTitle(v),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter title' : null,
                  ),
                  const Gap(20),

                  // ── Date picker ─────────────────────────────────────
                  _buildDatePicker(context, cubit, state.formDate),
                  const Gap(20),

                  // ── Note ────────────────────────────────────────────
                  CustomTextField(
                    label: 'Note (Optional)',
                    controller: _noteController,
                    hint: 'Add some details...',
                    onChanged: (v) => cubit.updateFormNote(v),
                    maxLines: 3,
                  ),
                  const Gap(32),

                  // ── Submit ──────────────────────────────────────────
                  CustomButton(
                    label: 'Save Transaction',
                    isLoading: state.isSubmitting,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState!.validate()) {
                        cubit.submitTransactionForm();
                      }
                    },
                  ),
                  const Gap(16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    TransactionCubit cubit,
    DateTime date,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppTextStyles.label.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black54
                : Colors.white,
          ),
        ),
        const Gap(8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => DatePickerSheet(
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onDateSelected: (newDate) => cubit.updateFormDate(newDate),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor ??
                  (Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[100]
                      : Theme.of(context).colorScheme.surface),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar,
                    size: 20, color: AppColors.primary),
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

  Widget _buildQuickAmounts(BuildContext context, TransactionCubit cubit) {
    final amounts = [10, 20, 50, 100, 200, 500];
    final authState = context.read<AuthCubit>().state;
    String symbol = r'$';
    if (authState is AuthAuthenticated) {
      symbol = authState.formatter.symbol;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: amounts.map((amount) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                _amountController.text = amount.toString();
                cubit.updateFormAmount(amount.toDouble());
                HapticFeedback.lightImpact();
                FocusScope.of(context).unfocus();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '$symbol$amount',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
