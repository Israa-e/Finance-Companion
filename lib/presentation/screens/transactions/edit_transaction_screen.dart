import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_constants.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/category_picker_sheet.dart';
import '../../shared/widgets/date_picker_sheet.dart';

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

  late DateTime _date;
  late TransactionType _type;
  late String _category;
  bool _isSubmitting = false;

  List<String> get _currentCategories => _type == TransactionType.income
      ? AppConstants.incomeCategories
      : AppConstants.expenseCategories;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController =
        TextEditingController(text: t.amount.toStringAsFixed(2));
    _titleController = TextEditingController(text: t.title);
    _noteController = TextEditingController(text: t.note ?? '');
    _date = t.date;
    _type = t.type;
    final valid = _currentCategories;
    _category = valid.contains(t.category) ? t.category : valid.last;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
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
              const Gap(8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.expense),
                  onPressed: () {
                    Navigator.pop(ctx);
                    cubit.deleteTransaction(widget.transaction.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
          IconButton(
            icon: const Icon(Iconsax.trash,
                color: AppColors.expense, size: 20),
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
              _TypeToggle(
                selected: _type,
                onChanged: (type) => setState(() {
                  _type = type;
                  _category = _currentCategories.first;
                }),
              ),
              const Gap(24),
              CustomTextField(
                label: 'Amount',
                controller: _amountController,
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const Gap(20),
              _CategorySelection(
                selected: _category,
                isIncome: _type == TransactionType.income,
                onChanged: (cat) => setState(() => _category = cat),
              ),
              const Gap(20),
              CustomTextField(
                label: 'Title',
                controller: _titleController,
                hint: 'e.g. Grocery Shopping',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter title' : null,
              ),
              const Gap(20),
              _DatePicker(
                date: _date,
                onPick: (picked) => setState(() => _date = picked),
              ),
              const Gap(20),
              CustomTextField(
                label: 'Note (Optional)',
                controller: _noteController,
                hint: 'Add some details...',
                maxLines: 3,
              ),
              const Gap(32),
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
}

// ─── Internal Widgets ────────────────────────────────────────────────────────

class _CategorySelection extends StatelessWidget {
  final String selected;
  final bool isIncome;
  final ValueChanged<String> onChanged;

  const _CategorySelection({
    required this.selected,
    required this.isIncome,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final icon = CategoryPickerSheet.getIcon(selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.label.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => CategoryPickerSheet(
                selectedCategory: selected,
                isIncome: isIncome,
                onCategorySelected: onChanged,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor ??
                  (Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[100]
                      : Theme.of(context).colorScheme.surface),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.primary),
                const Gap(12),
                Expanded(
                  child: Text(selected, style: AppTextStyles.body),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
                onDateSelected: onPick,
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
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}