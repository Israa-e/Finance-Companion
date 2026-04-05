import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:finance_companion/l10n/app_localizations.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../logic/goal/goal_state.dart';
import '../../../logic/transaction/transaction_filter_cubit.dart';
import '../../../logic/transaction/transaction_action_cubit.dart';
import '../../../logic/transaction/transaction_form_cubit.dart';
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
import 'package:uuid/uuid.dart';

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
  void initState() {
    super.initState();
    context.read<TransactionFormCubit>().reset();
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
              title: Text(l10n.addTransaction, style: AppTextStyles.h3),
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
                        final locked = goalState is GoalLoaded ? goalState.totalLocked : 0.0;
                        final available = (filterState.balance - locked).clamp(0.0, double.infinity);

                        if (state.type == TransactionType.expense && val > available) {
                          final authState = context.read<AuthCubit>().state;
                          final formatter = authState is AuthAuthenticated ? authState.formatter : const CurrencyFormatter();
                          return l10n.onlyAvailable(formatter.format(available));
                        }
                        return null;
                      },
                    ),
                    _buildAvailableInfo(context),
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
                          final authState = context.read<AuthCubit>().state;
                          if (authState is AuthAuthenticated) {
                            final tx = TransactionModel(
                              id: const Uuid().v4(),
                              userId: authState.user.id!,
                              amount: state.amount,
                              type: state.type,
                              category: state.category,
                              date: state.date,
                              title: state.title,
                              note: state.note,
                              lastUpdated: DateTime.now(),
                            );
                            actionCubit.addTransaction(tx);
                          }
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

  Widget _buildAvailableInfo(BuildContext context) {
    return BlocBuilder<TransactionFilterCubit, TransactionFilterState>(
      builder: (context, filterState) {
        final formState = context.read<TransactionFormCubit>().state;
        if (formState.type != TransactionType.expense) return const SizedBox.shrink();

        final goalState = context.watch<GoalCubit>().state;
        final locked = goalState is GoalLoaded ? goalState.totalLocked : 0.0;
        final available = (filterState.balance - locked).clamp(0.0, double.infinity);

        final authState = context.watch<AuthCubit>().state;
        final formatter = authState is AuthAuthenticated ? authState.formatter : const CurrencyFormatter();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: available < 50 ? AppColors.expense : AppColors.textSecondary),
                  const Gap(5),
                  Text(
                    '${AppLocalizations.of(context)!.availableToSpend}: ${formatter.formatCompact(available)}',
                    style: AppTextStyles.caption.copyWith(
                      color: available < 50 ? AppColors.expense : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            _buildQuickAmounts(context, available),
          ],
        );
      },
    );
  }

  Widget _buildQuickAmounts(BuildContext context, double available) {
    final amounts = [10, 20, 50, 100, 200, 500];
    final authState = context.read<AuthCubit>().state;
    final symbol = authState is AuthAuthenticated ? authState.formatter.symbol : r'$';

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
                context.read<TransactionFormCubit>().updateAmount(amount.toDouble());
                HapticFeedback.lightImpact();
                FocusScope.of(context).unfocus();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Text('$symbol$amount', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, TransactionFormCubit cubit, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.date, style: AppTextStyles.label.copyWith(color: Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white)),
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
                onDateSelected: (newDate) => cubit.updateDate(newDate),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor ?? (Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Theme.of(context).colorScheme.surface),
              borderRadius: BorderRadius.circular(12),
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
}
