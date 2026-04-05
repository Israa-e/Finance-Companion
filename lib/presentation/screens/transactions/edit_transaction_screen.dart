import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:finance_companion/l10n/app_localizations.dart';
import '../../../logic/transaction/transaction_action_cubit.dart';
import '../../../logic/transaction/transaction_form_cubit.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/date_picker_sheet.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/transaction_category_dropdown.dart';
import '../../../logic/transaction/transaction_filter_cubit.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../logic/goal/goal_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController = TextEditingController(text: t.amount.toStringAsFixed(2));
    _titleController = TextEditingController(text: t.title);
    _noteController = TextEditingController(text: t.note ?? '');
    
    // Initialize form cubit with existing data
    context.read<TransactionFormCubit>().initForEdit(t);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionActionCubit, TransactionActionState>(
          listener: (context, state) {
            if (state is TransactionActionSuccess) {
              Navigator.pop(context);
            }
            if (state is TransactionActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.expense),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<TransactionFormCubit, TransactionFormState>(
        builder: (context, state) {
          final formCubit = context.read<TransactionFormCubit>();
          final actionCubit = context.read<TransactionActionCubit>();
          final l10n = AppLocalizations.of(context)!;

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.editTransaction, style: AppTextStyles.h3),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const BackButton(),
              actions: [
                IconButton(
                  icon: const Icon(Iconsax.trash, color: AppColors.expense, size: 20),
                  onPressed: () => _confirmDelete(context, actionCubit),
                ),
              ],
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
                      label: l10n.amount,
                      controller: _amountController,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) {
                        final val = double.tryParse(v);
                        if (val != null) formCubit.updateAmount(val);
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.enterAmount;
                        final val = double.tryParse(v);
                        if (val == null || val <= 0) return l10n.invalidAmount;

                        final filterState = context.read<TransactionFilterCubit>().state;
                        final goalState = context.read<GoalCubit>().state;
                        
                        double currentBalance = filterState.balance;
                        if (widget.transaction.type == TransactionType.expense) {
                          currentBalance += widget.transaction.amount;
                        }

                        final locked = goalState is GoalLoaded ? goalState.totalLocked : 0.0;
                        final available = (currentBalance - locked).clamp(0.0, double.infinity);

                        if (state.type == TransactionType.expense && val > available) {
                          final authState = context.read<AuthCubit>().state;
                          final formatter = authState is AuthAuthenticated ? authState.formatter : const CurrencyFormatter();
                          return l10n.onlyAvailable(formatter.format(available));
                        }
                        return null;
                      },
                    ),
                    _buildAvailableInfo(context, state),
                    const Gap(14),
                    const TransactionCategoryDropdown(),
                    const Gap(20),
                    CustomTextField(
                      label: l10n.title,
                      controller: _titleController,
                      hint: l10n.groceryShoppingHint,
                      onChanged: (v) => formCubit.updateTitle(v),
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.enterTitle : null,
                    ),
                    const Gap(20),
                    _buildDatePicker(context, formCubit, state.date),
                    const Gap(20),
                    CustomTextField(
                      label: l10n.note,
                      controller: _noteController,
                      hint: l10n.addDetailsHint,
                      onChanged: (v) => formCubit.updateNote(v),
                      maxLines: 3,
                    ),
                    const Gap(32),
                    CustomButton(
                      label: l10n.save,
                      isLoading: context.watch<TransactionActionCubit>().state is TransactionActionLoading,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          final updated = widget.transaction.copyWith(
                            amount: state.amount,
                            type: state.type,
                            category: state.category,
                            date: state.date,
                            title: state.title,
                            note: state.note.isEmpty ? null : state.note,
                            lastUpdated: DateTime.now(),
                          );
                          actionCubit.updateTransaction(updated);
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
      ),
    );
  }

  void _confirmDelete(BuildContext context, TransactionActionCubit actionCubit) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteTransactionConfirm(widget.transaction.title)),
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                  onPressed: () {
                    Navigator.pop(ctx);
                    actionCubit.deleteTransaction(widget.transaction.id);
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

  Widget _buildDatePicker(BuildContext context, TransactionFormCubit cubit, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.date,
          style: AppTextStyles.label.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const Gap(8),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => DatePickerSheet(
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onDateSelected: (newDate) => cubit.updateDate(newDate),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor ?? (Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Theme.of(context).colorScheme.surface),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar, size: 20, color: AppColors.primary),
                const Gap(12),
                Text('${date.day}/${date.month}/${date.year}', style: AppTextStyles.body),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableInfo(BuildContext context, TransactionFormState formState) {
    if (formState.type != TransactionType.expense) return const SizedBox.shrink();

    final filterState = context.watch<TransactionFilterCubit>().state;
    final goalState = context.watch<GoalCubit>().state;
    
    double currentBalance = filterState.balance;
    if (widget.transaction.type == TransactionType.expense) {
      currentBalance += widget.transaction.amount;
    }
    
    final locked = goalState is GoalLoaded ? goalState.totalLocked : 0.0;
    final available = (currentBalance - locked).clamp(0.0, double.infinity);

    final authState = context.watch<AuthCubit>().state;
    final l10n = AppLocalizations.of(context)!;
    final formatter = authState is AuthAuthenticated ? authState.formatter : const CurrencyFormatter();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Iconsax.info_circle, 
                size: 14, 
                color: available > 0 ? AppColors.primary : AppColors.expense
              ),
              const Gap(6),
              Text(
                '${l10n.availableToSpend}: ${formatter.format(available)}',
                style: AppTextStyles.caption.copyWith(
                  color: available > 0 ? AppColors.primary : AppColors.expense,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}