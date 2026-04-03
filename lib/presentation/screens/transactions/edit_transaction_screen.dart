import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

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

  late TransactionType _type;
  late String _category;
  late DateTime _date;
  bool _isSubmitting = false;

  static const _expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Rent',
    'Entertainment',
    'Health',
    'Travel',
    'Other',
  ];

  static const _incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController =
        TextEditingController(text: t.amount.toStringAsFixed(2));
    _titleController = TextEditingController(text: t.title);
    _noteController = TextEditingController(text: t.note ?? '');
    _type = t.type;
    _date = t.date;

    // Ensure category is valid for the type
    final validCategories = _type == TransactionType.income
        ? _incomeCategories
        : _expenseCategories;
    _category = validCategories.contains(t.category)
        ? t.category
        : validCategories.last;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _currentCategories =>
      _type == TransactionType.income ? _incomeCategories : _expenseCategories;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final updated = widget.transaction.copyWith(
      amount: double.parse(_amountController.text),
      type: _type,
      category: _category,
      date: _date,
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    try {
      await context.read<TransactionCubit>().updateTransaction(updated);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction', style: AppTextStyles.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        actions: [
          // Delete button in app bar
          IconButton(
            icon: const Icon(Iconsax.trash, color: AppColors.expense, size: 20),
            onPressed: () => _confirmDelete(context),
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
              // ── Type toggle ──────────────────────────────────────────
              _TypeToggle(
                selected: _type,
                onChanged: (type) {
                  setState(() {
                    _type = type;
                    // Reset category to first valid option on type change
                    _category = _currentCategories.first;
                  });
                },
              ),
              const Gap(24),

              // ── Amount ───────────────────────────────────────────────
              CustomTextField(
                label: 'Amount',
                controller: _amountController,
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const Gap(20),

              // ── Category ─────────────────────────────────────────────
              _CategoryDropdown(
                categories: _currentCategories,
                selected: _category,
                onChanged: (cat) => setState(() => _category = cat),
              ),
              const Gap(20),

              // ── Title ────────────────────────────────────────────────
              CustomTextField(
                label: 'Title',
                controller: _titleController,
                hint: 'e.g. Grocery Shopping',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter title' : null,
              ),
              const Gap(20),

              // ── Date picker ──────────────────────────────────────────
              _DatePicker(
                date: _date,
                onPick: (picked) => setState(() => _date = picked),
              ),
              const Gap(20),

              // ── Note ─────────────────────────────────────────────────
              CustomTextField(
                label: 'Note (Optional)',
                controller: _noteController,
                hint: 'Add some details...',
                maxLines: 3,
              ),
              const Gap(32),

              // ── Save button ──────────────────────────────────────────
              CustomButton(
                label: 'Save Changes',
                isLoading: _isSubmitting,
                onTap: _submit,
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final cubit = context.read<TransactionCubit>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('Remove "${widget.transaction.title}" permanently?'),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.expense),
                  onPressed: () {
                    Navigator.pop(ctx);
                    cubit.deleteTransaction(widget.transaction.id);
                    Navigator.pop(context); // also pop edit screen
                  },
                  child: const Text('Delete'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Type Toggle ──────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor ??
            (Theme.of(context).brightness == Brightness.light
                ? Colors.grey[100]
                : Theme.of(context).colorScheme.surface),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Expense',
              isSelected: selected == TransactionType.expense,
              color: AppColors.expense,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ToggleButton(
              label: 'Income',
              isSelected: selected == TransactionType.income,
              color: AppColors.income,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category Dropdown ───────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategoryDropdown({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.label.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor ??
                (Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[100]
                    : Theme.of(context).colorScheme.surface),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: categories.contains(selected) ? selected : categories.last,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.35),
              ),
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: categories
                  .map(
                      (c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Date Picker ─────────────────────────────────────────────────────────────

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _DatePicker({required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppTextStyles.label.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const Gap(8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) onPick(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}
