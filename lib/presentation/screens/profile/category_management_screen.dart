import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../../../logic/category/category_cubit.dart';
import '../../../data/models/category_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/category_assets.dart';
import 'package:finance_companion/l10n/app_localizations.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageCategories,
            style: AppTextStyles.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryLoaded) {
            final userCategories =
                state.categories.where((c) => c.userId != null).toList();
            final systemCategories =
                state.categories.where((c) => c.userId == null).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              children: [
                if (userCategories.isNotEmpty) ...[
                  _SectionHeader(
                      title: AppLocalizations.of(context)!.customCategories,
                      count: userCategories.length),
                  const Gap(12),
                  ...userCategories
                      .map((c) => _CategoryTile(category: c, isCustom: true)),
                  const Gap(32),
                ],
                _SectionHeader(
                    title: AppLocalizations.of(context)!.standardCategories,
                    count: systemCategories.length),
                const Gap(12),
                ...systemCategories
                    .map((c) => _CategoryTile(category: c, isCustom: false)),
              ],
            );
          }

          if (state is CategoryError) {
            return Center(
                child: Text(state.message,
                    style: TextStyle(color: AppColors.expense)));
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategorySheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(AppLocalizations.of(context)!.addCategory,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context) {
    final categoryCubit = context.read<CategoryCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: categoryCubit,
        child: const _AddCategorySheet(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.caption.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final bool isCustom;

  const _CategoryTile({required this.category, required this.isCustom});

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            category.userId == null
                ? IconData(category.iconCode,
                    fontFamily: 'Iconsax', fontPackage: 'iconsax')
                : IconData(category.iconCode, fontFamily: 'MaterialIcons'),
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          category.name,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          category.type.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: category.isIncome ? AppColors.income : AppColors.expense,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        trailing: isCustom
            ? IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.trash,
                      color: AppColors.expense, size: 16),
                ),
                onPressed: () => _confirmDelete(context),
              )
            : const Icon(Iconsax.lock, size: 16, color: Colors.grey),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirm(category.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              context.read<CategoryCubit>().deleteCategory(category.id);
              Navigator.pop(ctx);
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet();

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  String _type = 'expense';
  int _selectedIconCode = CategoryIcons.icons.values.first.codePoint;
  Color _selectedColor = CategoryColors.colors.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.createCategory,
                  style: AppTextStyles.h2),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          const Gap(24),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: AppTextStyles.h3,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.categoryName,
              hintText: AppLocalizations.of(context)!.subscriptionsHint,
              labelStyle: AppTextStyles.label,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              prefixIcon: Icon(
                  IconData(_selectedIconCode,
                      fontFamily: 'Iconsax', fontPackage: 'iconsax'),
                  color: _selectedColor),
            ),
          ),
          const Gap(24),
          Row(
            children: [
              _TypeTab(
                  label: AppLocalizations.of(context)!.expense,
                  isSelected: _type == 'expense',
                  color: AppColors.expense,
                  onTap: () => setState(() => _type = 'expense')),
              const Gap(12),
              _TypeTab(
                  label: AppLocalizations.of(context)!.income,
                  isSelected: _type == 'income',
                  color: AppColors.income,
                  onTap: () => setState(() => _type = 'income')),
            ],
          ),
          const Gap(24),
          Text(AppLocalizations.of(context)!.selectIcon,
              style: AppTextStyles.label),
          const Gap(12),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: CategoryIcons.icons.length,
              separatorBuilder: (_, __) => const Gap(12),
              itemBuilder: (context, index) {
                final iconData = CategoryIcons.icons.values.elementAt(index);
                final isSelected = _selectedIconCode == iconData.codePoint;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedIconCode = iconData.codePoint),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.1),
                          width: 2),
                    ),
                    child: Icon(iconData,
                        color: isSelected ? _selectedColor : Colors.grey,
                        size: 24),
                  ),
                );
              },
            ),
          ),
          const Gap(24),
          Text(AppLocalizations.of(context)!.selectColor,
              style: AppTextStyles.label),
          const Gap(12),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: CategoryColors.colors.length,
              separatorBuilder: (_, __) => const Gap(12),
              itemBuilder: (context, index) {
                final color = CategoryColors.colors[index];
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
          const Gap(32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  context.read<CategoryCubit>().addCategory(
                        name: _nameController.text,
                        iconCode: _selectedIconCode,
                        colorValue: _selectedColor.value,
                        type: _type,
                      );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: Text(AppLocalizations.of(context)!.createCategory,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeTab(
      {required this.label,
      required this.isSelected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected
                    ? color
                    : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: 2),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
