import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/transaction/transaction_state.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/transaction_list_item.dart';
import 'widgets/transaction_search_bar.dart';
import 'widgets/transaction_filter_row.dart';
import 'package:gap/gap.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10), // Ultra dark background
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
                      return _buildEmptyState(state.searchQuery.isNotEmpty);
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
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color:
                                          Colors.white.withValues(alpha: 0.05),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...transactions.map((tx) => TransactionListItem(
                                  transaction: tx,
                                  onEdit: () {
                                    // TODO: Implement edit
                                  },
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

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Iconsax.search_status : Iconsax.receipt_item,
            size: 64,
            color: Colors.grey[800],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No transactions found' : 'No transactions yet',
            style: AppTextStyles.h3.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term'
                : 'Your transactions will appear here',
            style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
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
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '$count entries',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/add-transaction'),
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
