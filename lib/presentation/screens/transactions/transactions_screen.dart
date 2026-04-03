import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/transaction/transaction_state.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/transaction_model.dart';

import 'edit_transaction_screen.dart';
import 'add_transaction_screen.dart';
import 'widgets/transaction_list_item.dart';
import 'widgets/transaction_search_bar.dart';
import 'widgets/transaction_filter_row.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const TransactionSearchBar(),
            const TransactionFilterRow(),
            Expanded(
              child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TransactionLoaded) {
                    final groupedByDate = state.groupedTransactions;

                    if (groupedByDate.isEmpty) {
                      return _buildEmptyState(
                          context, state.searchQuery.isNotEmpty);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      itemCount: groupedByDate.length,
                      itemBuilder: (context, index) {
                        final date = groupedByDate.keys.elementAt(index);
                        final transactions = groupedByDate[date]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Text(
                                    date,
                                    style: AppTextStyles.label.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.07),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...transactions.map((tx) => TransactionListItem(
                                  transaction: tx,
                                  onEdit: () => _navigateToEdit(context, tx),
                                  onDelete: () => context
                                      .read<TransactionCubit>()
                                      .deleteTransaction(tx.id),
                                )),
                          ],
                        );
                      },
                    );
                  }

                  if (state is TransactionError) {
                    return Center(child: Text(state.message));
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, TransactionModel tx) {
    final txCubit = context.read<TransactionCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: txCubit,
          child: EditTransactionScreen(transaction: tx),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Iconsax.search_status : Iconsax.receipt_item,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No transactions found' : 'No transactions yet',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term'
                : 'Your transactions will appear here',
            style: AppTextStyles.body.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          final count = state is TransactionLoaded
              ? state.filteredTransactions.length
              : 0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transactions',
                    style: AppTextStyles.h2,
                  ),
                  const Gap(4),
                  Text(
                    '$count entries',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  final txCubit = context.read<TransactionCubit>();
                  final goalCubit = context.read<GoalCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: txCubit),
                          BlocProvider.value(value: goalCubit),
                        ],
                        child: const AddTransactionScreen(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
