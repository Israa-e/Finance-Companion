import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../transactions/widgets/transaction_list_item.dart';
import '../../transactions/edit_transaction_screen.dart';

class CategoryDrilldownSheet extends StatelessWidget {
  final String category;
  final List<TransactionModel> transactions;

  const CategoryDrilldownSheet({
    super.key,
    required this.category,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where((t) => t.category == category).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const Gap(12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      category,
                      style: AppTextStyles.h3,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filtered.length} entries',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions in this category.',
                          style: AppTextStyles.bodySmall,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return TransactionListItem(
                            transaction: tx,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditTransactionScreen(transaction: tx),
                                ),
                              );
                            },
                            onDelete: () {
                              context
                                  .read<TransactionCubit>()
                                  .deleteTransaction(tx.id);
                              // We don't pop here as the list should refresh automatically
                              // if BlocBuilder is used, but since this is a stateless sheet
                              // using a passed list, we might need a pop or a refresh.
                              // However, TransactionCubit.delete will trigger onMutated
                              // which refreshes the underlying data.
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
