import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CategoryPickerSheet extends StatelessWidget {
  final String selectedCategory;
  final bool isIncome;
  final Function(String) onCategorySelected;

  const CategoryPickerSheet({
    super.key,
    required this.selectedCategory,
    required this.isIncome,
    required this.onCategorySelected,
  });

  static IconData getIcon(String category) {
    switch (category) {
      case 'Food & Drinks': return Iconsax.coffee;
      case 'Shopping': return Iconsax.shopping_bag;
      case 'Transport': return Iconsax.car;
      case 'Housing': return Iconsax.house;
      case 'Entertainment': return Iconsax.game;
      case 'Health': return Iconsax.health;
      case 'Travel': return Iconsax.airplane;
      case 'Education': return Iconsax.book;
      case 'Salary': return Iconsax.wallet_3;
      case 'Freelance': return Iconsax.briefcase;
      case 'Investment': return Iconsax.chart_2;
      case 'Gift': return Iconsax.gift;
      default: return Iconsax.more_square;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = isIncome 
        ? AppConstants.incomeCategories 
        : AppConstants.expenseCategories;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),
          Text(
            'Select Category',
            style: AppTextStyles.h3,
          ),
          const Gap(24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;
              final icon = getIcon(category);

              return GestureDetector(
                onTap: () {
                  onCategorySelected(category);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? Colors.white : AppColors.primary,
                        size: 28,
                      ),
                      const Gap(8),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Gap(24),
        ],
      ),
    );
  }
}
