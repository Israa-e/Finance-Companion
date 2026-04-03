import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TransactionCategoryDropdown extends StatelessWidget {
  const TransactionCategoryDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) return const SizedBox.shrink();
        final cubit = context.read<TransactionCubit>();

        final categories = state.formType == TransactionType.income
            ? ['Salary', 'Freelance', 'Investment', 'Gift', 'Other']
            : ['Food', 'Transport', 'Shopping', 'Rent', 'Entertainment', 'Health', 'Travel', 'Other'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: categories.contains(state.formCategory) ? state.formCategory : categories.last,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  style: AppTextStyles.body,
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) cubit.updateFormCategory(v);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
