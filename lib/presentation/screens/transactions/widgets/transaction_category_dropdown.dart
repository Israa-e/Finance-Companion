import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import '../../../shared/widgets/category_picker_sheet.dart';

class TransactionCategoryDropdown extends StatelessWidget {
  const TransactionCategoryDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) return const SizedBox.shrink();
        final cubit = context.read<TransactionCubit>();

        final isIncome = state.formType == TransactionType.income;
        final icon = CategoryPickerSheet.getIcon(state.formCategory);

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
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CategoryPickerSheet(
                    selectedCategory: state.formCategory,
                    isIncome: isIncome,
                    onCategorySelected: (cat) => cubit.updateFormCategory(cat),
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
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: AppColors.primary,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        state.formCategory,
                        style: AppTextStyles.body.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
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