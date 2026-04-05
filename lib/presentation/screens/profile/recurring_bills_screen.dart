import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:finance_companion/logic/recurring/recurring_cubit.dart';
import 'package:finance_companion/data/models/recurring_transaction_model.dart';
import 'package:finance_companion/logic/category/category_cubit.dart';
import 'package:finance_companion/core/theme/app_colors.dart';
import 'package:finance_companion/core/theme/app_text_styles.dart';
import 'package:finance_companion/presentation/shared/widgets/category_picker_sheet.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/auth/auth_state.dart';
import 'package:finance_companion/core/utils/currency_formatter.dart';
import 'package:finance_companion/l10n/app_localizations.dart';

class RecurringBillsScreen extends StatelessWidget {
  const RecurringBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recurringBills,
            style: AppTextStyles.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) return const SizedBox.shrink();
          final formatter = authState.formatter;

          return BlocBuilder<RecurringCubit, RecurringState>(
            builder: (context, state) {
              if (state is RecurringLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is RecurringLoaded) {
                if (state.templates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.repeat,
                            size: 64,
                            color: Colors.grey.withValues(alpha: 0.3)),
                        const Gap(16),
                        Text(AppLocalizations.of(context)!.noRecurringBills,
                            style: AppTextStyles.body),
                        const Gap(8),
                        Text(
                            AppLocalizations.of(context)!.addRecurringBillsHint,
                            style: AppTextStyles.caption),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.templates.length,
                  itemBuilder: (context, index) {
                    final template = state.templates[index];
                    return _RecurringTile(
                        template: template, formatter: formatter);
                  },
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBillSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddBillSheet(BuildContext context) {
    final recurringCubit = context.read<RecurringCubit>();
    final categoryCubit = context.read<CategoryCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: recurringCubit),
          BlocProvider.value(value: categoryCubit),
        ],
        child: const _AddRecurringBillSheet(),
      ),
    );
  }
}

class _RecurringTile extends StatelessWidget {
  final RecurringTransactionModel template;
  final CurrencyFormatter formatter;

  const _RecurringTile({required this.template, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: template.type == 'income'
                ? AppColors.income.withValues(alpha: 0.1)
                : AppColors.expense.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            template.type == 'income' ? Iconsax.arrow_up_1 : Iconsax.arrow_down,
            color: template.type == 'income'
                ? AppColors.income
                : AppColors.expense,
            size: 20,
          ),
        ),
        title: Text(
          template.title,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${AppLocalizations.of(context)!.next}: ${DateFormat('MMM dd').format(template.nextDate)} (${template.frequency.name})',
          style: AppTextStyles.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatter.format(template.amount),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: template.type == 'income'
                    ? AppColors.income
                    : AppColors.expense,
              ),
            ),
            const Gap(8),
            Switch.adaptive(
              value: template.isActive,
              activeColor: AppColors.primary,
              onChanged: (_) =>
                  context.read<RecurringCubit>().toggleActive(template),
            ),
          ],
        ),
        onLongPress: () {
          final l10n = AppLocalizations.of(context)!;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(l10n.deleteRecurringBill),
              content: Text(l10n.deleteRecurringBillConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () {
                    context.read<RecurringCubit>().deleteTemplate(template.id);
                    Navigator.pop(ctx);
                  },
                  child: Text(l10n.delete,
                      style: const TextStyle(color: AppColors.expense)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddRecurringBillSheet extends StatefulWidget {
  const _AddRecurringBillSheet();

  @override
  State<_AddRecurringBillSheet> createState() => _AddRecurringBillSheetState();
}

class _AddRecurringBillSheetState extends State<_AddRecurringBillSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Bills';
  final String _type = 'expense';
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  final DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.newRecurringBill,
                style: AppTextStyles.h3),
            const Gap(24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                  hintText: AppLocalizations.of(context)!.netflixHint),
            ),
            const Gap(16),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amount,
                prefixText:
                    '${(context.read<AuthCubit>().state as AuthAuthenticated).user.currency} ',
              ),
            ),
            const Gap(20),
            _buildCategoryPicker(context),
            const Gap(20),
            _buildFrequencyPicker(),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text);
                  if (_titleController.text.isNotEmpty && amount != null) {
                    context.read<RecurringCubit>().addTemplate(
                          title: _titleController.text,
                          amount: amount,
                          type: _type,
                          category: _category,
                          frequency: _frequency,
                          nextDate: _startDate,
                        );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(AppLocalizations.of(context)!.addRecurringBill,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPicker(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => BlocProvider.value(
            value: context.read<CategoryCubit>(),
            child: CategoryPickerSheet(
              selectedCategory: _category,
              isIncome: _type == 'income',
              onCategorySelected: (cat) => setState(() => _category = cat),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_category, style: AppTextStyles.body),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyPicker() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: RecurringFrequency.values.map((f) {
        final isSelected = _frequency == f;
        String label = '';
        switch (f) {
          case RecurringFrequency.daily:
            label = l10n.daily;
            break;
          case RecurringFrequency.weekly:
            label = l10n.weekly;
            break;
          case RecurringFrequency.monthly:
            label = l10n.monthly;
            break;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _frequency = f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  label.toUpperCase(),
                  style: AppTextStyles.body.copyWith(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
