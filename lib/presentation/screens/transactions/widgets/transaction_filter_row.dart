import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import '../../../../core/theme/app_colors.dart';

class TransactionFilterRow extends StatelessWidget {
  const TransactionFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) return const SizedBox.shrink();

        final filters = [
          TransactionFilter.all,
          TransactionFilter.income,
          TransactionFilter.expense,
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: filters.map((filter) {
              final isSelected = state.activeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () =>
                      context.read<TransactionCubit>().updateFilter(filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
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
                      filter.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.light
                                ? Colors.black54
                                : Colors.white),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
