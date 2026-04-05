import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import 'package:finance_companion/logic/category/category_cubit.dart';
import 'package:finance_companion/data/models/category_model.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:finance_companion/l10n/app_localizations.dart';

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

  static IconData getIcon(dynamic category) {
    if (category is CategoryModel) {
      // System categories (userId is null) use Iconsax fonts
      if (category.userId == null) {
        return IconData(category.iconCode,
            fontFamily: 'Iconsax', fontPackage: 'iconsax');
      }
      return IconData(category.iconCode, fontFamily: 'MaterialIcons');
    }
    // Fallback for string-based calls if any remains during transition
    switch (category.toString()) {
      case 'Food':
        return Iconsax.coffee;
      case 'Shopping':
        return Iconsax.shopping_bag;
      case 'Transport':
        return Iconsax.car;
      case 'Rent':
        return Iconsax.house;
      case 'Entertainment':
        return Iconsax.game;
      case 'Health':
        return Iconsax.health;
      case 'Bills':
        return Iconsax.bill;
      case 'Salary':
        return Iconsax.wallet_3;
      case 'Freelance':
        return Iconsax.briefcase;
      case 'Investment':
        return Iconsax.chart_2;
      case 'Gift':
        return Iconsax.gift;
      default:
        return Iconsax.more_square;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        List<CategoryModel> categories = [];
        if (state is CategoryLoaded) {
          categories =
              isIncome ? state.incomeCategories : state.expenseCategories;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                l10n.selectCategory,
                style: AppTextStyles.h3,
              ),
              const Gap(24),
              if (state is CategoryLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                )
              else if (categories.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child:
                      Text(l10n.noCategoriesFound, style: AppTextStyles.body),
                )
              else
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category.name == selectedCategory;

                      // System categories (userId is null) use Iconsax fonts
                      final IconData icon = category.userId == null
                          ? IconData(category.iconCode,
                              fontFamily: 'Iconsax', fontPackage: 'iconsax')
                          : IconData(category.iconCode,
                              fontFamily: 'MaterialIcons');

                      return GestureDetector(
                        onTap: () {
                          onCategorySelected(category.name);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(category.colorValue)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Color(category.colorValue)
                                  : Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                color: isSelected
                                    ? Colors.white
                                    : Color(category.colorValue),
                                size: 28,
                              ),
                              const Gap(8),
                              Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const Gap(24),
            ],
          ),
        );
      },
    );
  }
}
