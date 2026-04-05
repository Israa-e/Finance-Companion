import 'package:finance_companion/presentation/shared/widgets/category_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:finance_companion/logic/category/category_cubit.dart';
import '../../../../logic/transaction/transaction_form_cubit.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TransactionCategoryDropdown extends StatelessWidget {
  const TransactionCategoryDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFormCubit, TransactionFormState>(
      builder: (context, state) {
        final icon = CategoryPickerSheet.getIcon(state.category);

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
                final categoryCubit = context.read<CategoryCubit>();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => BlocProvider.value(
                    value: categoryCubit,
                    child: CategoryPickerSheet(
                      selectedCategory: state.category,
                      isIncome: state.type == TransactionType.income,
                      onCategorySelected: (cat) =>
                          context.read<TransactionFormCubit>().updateCategory(cat),
                    ),
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
                      child: Text(state.category, style: AppTextStyles.body),
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
      },
    );
  }
}