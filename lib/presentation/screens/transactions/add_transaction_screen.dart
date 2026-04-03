import 'package:finance_companion/core/utils/currency_formatter.dart';
import 'package:finance_companion/logic/goal/goal_state.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/utils/date_formatter.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _category = AppConstants.expenseCategories.first;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  // Computed once in initState / on type change — never called during build.
  double _availableBalance = 0.0;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final t = widget.transaction!;
      _titleController.text = t.title;
      _amountController.text = t.amount.toString();
      _noteController.text = t.note ?? '';
      _type = t.type;
      _category = t.category;
      _date = t.date;
    }
    _dateController.text = DateFormatter.formatFull(_date);

    // Compute available balance once, safely, after the first frame
    // so all cubits are guaranteed to be in scope.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAvailableBalance();
    });
  }

  void _refreshAvailableBalance() {
    if (!mounted) return;
    final txState = context.read<TransactionCubit>().state;
    final goalState = _safeGoalState();
    final balance = txState is TransactionLoaded ? txState.balance : 0.0;
    final locked = goalState is GoalLoaded
        ? goalState.goals.fold(0.0, (sum, goal) => sum + goal.savedAmount)
        : 0.0;

    // When editing an expense, the current transaction's amount is already
    // deducted from the balance, so add it back to get the true ceiling.
    final editingOffset =
        isEditing && widget.transaction!.type == TransactionType.expense
        ? widget.transaction!.amount
        : 0.0;

    setState(() {
      _availableBalance = (balance - locked + editingOffset).clamp(
        0.0,
        double.infinity,
      );
    });
  }

  GoalState? _safeGoalState() {
    try {
      return context.read<GoalCubit>().state;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: AppTextStyles.h3,
        ),
        leading: const BackButton(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeToggle(),
              const Gap(20),
              CustomTextField(
                label: 'Title',
                hint: 'e.g. Coffee at Starbucks',
                controller: _titleController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const Gap(16),
              CustomTextField(
                label: 'Amount',
                hint: '0.00',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                prefixIcon: const Icon(Iconsax.dollar_circle, size: 18),
                validator: _validateAmount,
              ),
              const Gap(16),
              _buildCategoryDropdown(),
              const Gap(16),
              CustomTextField(
                label: 'Date',
                controller: _dateController,
                readOnly: true,
                prefixIcon: const Icon(Iconsax.calendar, size: 18),
                onTap: _pickDate,
              ),
              const Gap(16),
              CustomTextField(
                label: 'Note (optional)',
                hint: 'Add a note...',
                controller: _noteController,
                maxLines: 3,
              ),
              const Gap(28),
              CustomButton(
                label: isEditing ? 'Update' : 'Add Transaction',
                isLoading: _isLoading,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Validation ─────────────────────────────────────────────────────────

  String? _validateAmount(String? v) {
    if (v == null || v.isEmpty) return 'Amount is required';
    final value = double.tryParse(v);
    if (value == null || value <= 0) return 'Enter a valid amount';
    // Only enforce balance ceiling for expenses
    if (_type == TransactionType.expense && value > _availableBalance) {
      return 'Only ${CurrencyFormatter.format(_availableBalance)} available';
    }
    return null;
  }

  // ─── Widgets ────────────────────────────────────────────────────────────

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TypeButton(
            label: 'Expense',
            isSelected: _type == TransactionType.expense,
            color: AppColors.expense,
            onTap: () => setState(() {
              _type = TransactionType.expense;
              _category = AppConstants.expenseCategories.first;
              _refreshAvailableBalance();
            }),
          ),
          _TypeButton(
            label: 'Income',
            isSelected: _type == TransactionType.income,
            color: AppColors.income,
            onTap: () => setState(() {
              _type = TransactionType.income;
              _category = AppConstants.incomeCategories.first;
              _refreshAvailableBalance();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = _type == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

    // Ensure _category is always a valid member of the current list.
    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.label),
        const Gap(6),
        DropdownButtonFormField<String>(
          value: _category, // 'value' not 'initialValue'
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _category = v);
          },
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).brightness == Brightness.dark
              ? const ColorScheme.dark(primary: AppColors.primary)
              : const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = DateFormatter.formatFull(picked);
      });
    }
  }

  // ─── Submit ──────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    // Re-sync balance before final validation in case time passed
    _refreshAvailableBalance();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final cubit = context.read<TransactionCubit>();
    final amount = double.parse(_amountController.text);
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    if (isEditing) {
      await cubit.updateTransaction(
        widget.transaction!.copyWith(
          title: _titleController.text.trim(),
          amount: amount,
          type: _type,
          category: _category,
          date: _date,
          note: note,
        ),
      );
    } else {
      await cubit.addTransaction(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        category: _category,
        date: _date,
        note: note,
      );
    }

    if (mounted) Navigator.pop(context);
  }
}

// ─── Type toggle button ──────────────────────────────────────────────────────

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected
                  ? Colors.white
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }
}
