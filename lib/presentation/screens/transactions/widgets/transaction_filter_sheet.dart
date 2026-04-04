import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  List<String> _selectedCategories = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final state = context.read<TransactionCubit>().state;
    if (state is TransactionLoaded) {
      _selectedCategories = List.from(state.selectedCategories);
      _startDate = state.customDateRange?.start;
      _endDate = state.customDateRange?.end;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = [
      ...AppConstants.expenseCategories,
      ...AppConstants.incomeCategories,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: AppTextStyles.h3),
              TextButton(
                onPressed: () {
                  context.read<TransactionCubit>().resetFilters();
                  Navigator.pop(context);
                },
                child: Text(
                  'Reset All',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.expense),
                ),
              ),
            ],
          ),
          const Gap(20),

          // Categories
          Text('Categories', style: AppTextStyles.label.copyWith(fontSize: 13)),
          const Gap(12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allCategories.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, index) {
                final category = allCategories[index];
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
                  ),
                );
              },
            ),
          ),
          const Gap(24),

          // Date Range
          Text('Date Range', style: AppTextStyles.label.copyWith(fontSize: 13)),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: _startDate != null 
                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' 
                      : 'Start Date',
                  icon: Iconsax.calendar_1,
                  onTap: () => _pickDate(context, true),
                ),
              ),
              const Gap(12),
              Expanded(
                child: _DateButton(
                  label: _endDate != null 
                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' 
                      : 'End Date',
                  icon: Iconsax.calendar_2,
                  onTap: () => _pickDate(context, false),
                ),
              ),
            ],
          ),
          const Gap(32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                final cubit = context.read<TransactionCubit>();
                cubit.updateSelectedCategories(_selectedCategories);
                cubit.updateCustomDateRange(_startDate, _endDate);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply Filters',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const Gap(8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
