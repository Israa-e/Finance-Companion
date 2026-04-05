import 'package:finance_companion/logic/goal/goal_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_form_cubit.dart';
import 'package:finance_companion/logic/category/category_cubit.dart';
import 'package:finance_companion/presentation/screens/home/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../../logic/transaction/transaction_filter_cubit.dart';
import '../../../logic/transaction/transaction_action_cubit.dart';
import '../../../logic/transaction/transaction_state.dart'; // Still need this for enums like TransactionFilter
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/transaction_model.dart';
import 'package:finance_companion/l10n/app_localizations.dart';

import '../../../data/services/csv_export_service.dart';
import 'edit_transaction_screen.dart';
import 'add_transaction_screen.dart';
import 'widgets/transaction_list_item.dart';
import 'widgets/transaction_search_bar.dart';
import '../../shared/widgets/sync_indicator.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final labelColor = Theme.of(context).colorScheme.onSurface;
    final dividerColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const TransactionSearchBar(),
            Expanded(
              child:
                  BlocBuilder<TransactionFilterCubit, TransactionFilterState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const TransactionListSkeleton();
                  }

                  final groupedByDate = state.groupedTransactions;

                  if (groupedByDate.isEmpty) {
                    final isSearching = state.searchQuery.isNotEmpty ||
                        state.activeFilter != TransactionFilter.all ||
                        state.selectedCategories.isNotEmpty;
                    return _buildEmptyState(context, isSearching);
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
                                    color: labelColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: dividerColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...transactions.map(
                            (tx) => TransactionListItem(
                              transaction: tx,
                              onEdit: () => _navigateToEdit(context, tx),
                              onDelete: () => context
                                  .read<TransactionActionCubit>()
                                  .deleteTransaction(tx.id),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, TransactionModel tx) {
    final actionCubit = context.read<TransactionActionCubit>();
    final formCubit = context.read<TransactionFormCubit>();
    final filterCubit = context.read<TransactionFilterCubit>();
    final goalCubit = context.read<GoalCubit>();
    final categoryCubit = context.read<CategoryCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: actionCubit),
            BlocProvider.value(value: formCubit),
            BlocProvider.value(value: filterCubit),
            BlocProvider.value(value: goalCubit),
            BlocProvider.value(value: categoryCubit),
          ],
          child: EditTransactionScreen(transaction: tx),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    final l10n = AppLocalizations.of(context)!;
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
          const Gap(16),
          Text(
            isSearching ? l10n.noTransactions : l10n.noTransactionsTitle,
            style: AppTextStyles.h3
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          const Gap(8),
          Text(
            isSearching ? l10n.tryDifferentSearch : l10n.transactionsAppearHere,
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
      child: BlocBuilder<TransactionFilterCubit, TransactionFilterState>(
        builder: (context, state) {
          final count = state.filteredTransactions.length;
          final l10n = AppLocalizations.of(context)!;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.transactions,
                    style: AppTextStyles.h2.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '$count',
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SyncIndicator(),
                  const Gap(12),
                  GestureDetector(
                    onTap: () {
                      final state =
                          context.read<TransactionFilterCubit>().state;
                      CSVExportService.exportTransactions(
                          state.filteredTransactions);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Iconsax.export,
                          color: AppColors.primary, size: 24),
                    ),
                  ),
                  const Gap(12),
                  GestureDetector(
                    onTap: () {
                      final actionCubit =
                          context.read<TransactionActionCubit>();
                      final formCubit = context.read<TransactionFormCubit>();
                      final filterCubit =
                          context.read<TransactionFilterCubit>();
                      final goalCubit = context.read<GoalCubit>();
                      final categoryCubit = context.read<CategoryCubit>();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: actionCubit),
                              BlocProvider.value(value: formCubit),
                              BlocProvider.value(value: filterCubit),
                              BlocProvider.value(value: goalCubit),
                              BlocProvider.value(value: categoryCubit),
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
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
