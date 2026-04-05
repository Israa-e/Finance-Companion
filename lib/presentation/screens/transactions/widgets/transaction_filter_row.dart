import 'package:finance_companion/l10n/app_localizations.dart';
import 'package:finance_companion/data/models/transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/transaction/transaction_filter_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TransactionFilterRow extends StatelessWidget {
  const TransactionFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFilterCubit, TransactionFilterState>(
      builder: (context, state) {
        final filters = TransactionFilter.values;
        final savedViews = state.savedViews;
        final totalCount = filters.length + savedViews.length;

        return SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: totalCount,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index < filters.length) {
                // Build normal filter
                final filter = filters[index];
                final isSelected = state.activeFilter == filter;
                return GestureDetector(
                  onTap: () => context
                      .read<TransactionFilterCubit>()
                      .updateFilter(filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.08),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      filter.label(context),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              } else {
                // Build saved view chip
                final viewIndex = index - filters.length;
                final view = savedViews[viewIndex];
                // Check if this saved view is currently applied (pseudo-selected state)
                final isSelected =
                    state.activeFilter == TransactionFilter.all &&
                        state.searchQuery == view.searchQuery &&
                        state.selectedCategories.join(',') ==
                            view.selectedCategories?.join(',');

                return GestureDetector(
                  onTap: () =>
                      context.read<TransactionFilterCubit>().applyView(view),
                  onLongPress: () => _confirmDelete(context, view),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      view.name,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, TransactionView view) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCustomView),
        content: Text(l10n.deleteCustomViewConfirm(view.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionFilterCubit>().deleteView(view.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
