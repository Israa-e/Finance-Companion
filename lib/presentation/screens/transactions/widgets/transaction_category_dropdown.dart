import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../core/theme/app_text_styles.dart';

class TransactionCategoryDropdown extends StatelessWidget {
  const TransactionCategoryDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) return const SizedBox.shrink();
        final cubit = context.read<TransactionCubit>();

        // ── Use AppConstants so names are always in sync ──────────────────
        final categories = state.formType == TransactionType.income
            ? AppConstants.incomeCategories
            : AppConstants.expenseCategories;

        // Guard: if current formCategory isn't in the list, fall back to last
        final currentCategory = categories.contains(state.formCategory)
            ? state.formCategory
            : categories.last;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: AppTextStyles.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
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
                  value: currentCategory,
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
                      .map((c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
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