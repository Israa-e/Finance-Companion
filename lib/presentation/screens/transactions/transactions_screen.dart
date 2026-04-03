import 'package:finance_companion/logic/goal/goal_cubit.dart';
import 'package:finance_companion/logic/insights/insights_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/transaction/transaction_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

// Combined filter — one value covers both type and date range.
enum _Filter { all, income, expense, today, thisWeek, thisMonth, lastMonth }

extension _FilterExt on _Filter {
  String get label {
    switch (this) {
      case _Filter.all:
        return 'All';
      case _Filter.income:
        return 'Income';
      case _Filter.expense:
        return 'Expense';
      case _Filter.today:
        return 'Today';
      case _Filter.thisWeek:
        return 'This week';
      case _Filter.thisMonth:
        return 'This month';
      case _Filter.lastMonth:
        return 'Last month';
    }
  }

  TransactionType? get type {
    if (this == _Filter.income) return TransactionType.income;
    if (this == _Filter.expense) return TransactionType.expense;
    return null;
  }

  DateRangeFilter? get dateRange {
    switch (this) {
      case _Filter.today:
        return DateRangeFilter.today;
      case _Filter.thisWeek:
        return DateRangeFilter.thisWeek;
      case _Filter.thisMonth:
        return DateRangeFilter.thisMonth;
      case _Filter.lastMonth:
        return DateRangeFilter.lastMonth;
      default:
        return null;
    }
  }
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  _Filter _activeFilter = _Filter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Navigation helper — always passes ALL three cubits ─────────────────
  void _openAddTransaction({TransactionModel? transaction}) {
    final txCubit = context.read<TransactionCubit>();
    final goalCubit = context.read<GoalCubit>();
    final insightsCubit = context.read<InsightsCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: txCubit),
            BlocProvider.value(value: goalCubit),
            BlocProvider.value(value: insightsCubit),
          ],
          child: AddTransactionScreen(transaction: transaction),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverToBoxAdapter(child: const Gap(10)),
                  SliverToBoxAdapter(child: _buildFilterRow()),
                  SliverToBoxAdapter(child: const Gap(4)),
                  _buildSliverList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transactions', style: AppTextStyles.h2),
                BlocBuilder<TransactionCubit, TransactionState>(
                  builder: (_, state) {
                    if (state is! TransactionLoaded)
                      return const SizedBox.shrink();
                    final count = state.transactions.length;
                    return Text(
                      '$count entries',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Add button
          GestureDetector(
            onTap: _openAddTransaction,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Search transactions…',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            prefixIcon: const Icon(
              Iconsax.search_normal,
              size: 18,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Single filter row ───────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _Filter.values.map((f) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: f.label,
                isSelected: _activeFilter == f,
                onTap: () => setState(() => _activeFilter = f),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Sliver list ─────────────────────────────────────────────────────────

  Widget _buildSliverList() {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is TransactionError) {
          return SliverFillRemaining(child: Center(child: Text(state.message)));
        }
        if (state is! TransactionLoaded) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final cubit = context.read<TransactionCubit>();
        final filtered = cubit.getFiltered(
          type: _activeFilter.type,
          searchQuery: _searchQuery,
          dateRange: _activeFilter.dateRange,
        );

        if (filtered.isEmpty) {
          return SliverFillRemaining(
            child: EmptyStateWidget(
              title: 'No transactions found',
              subtitle: _hasActiveFilters
                  ? 'Try adjusting your filters'
                  : 'Tap + to add your first transaction',
              icon: Iconsax.receipt,
            ),
          );
        }

        // Group by date
        final groups = _groupByDate(filtered);

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final entry = groups[i];
              return _DateGroup(
                label: entry.key,
                transactions: entry.value,
                onEdit: (t) => _openAddTransaction(transaction: t),
                onDelete: (t) =>
                    context.read<TransactionCubit>().deleteTransaction(t.id),
              );
            }, childCount: groups.length),
          ),
        );
      },
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  bool get _hasActiveFilters =>
      _activeFilter != _Filter.all || _searchQuery.isNotEmpty;

  List<MapEntry<String, List<TransactionModel>>> _groupByDate(
    List<TransactionModel> txs,
  ) {
    final map = <String, List<TransactionModel>>{};
    for (final t in txs) {
      final label = _labelFor(t.date);
      map.putIfAbsent(label, () => []).add(t);
    }
    return map.entries.toList();
  }

  String _labelFor(DateTime date) {
    if (DateFormatter.isToday(date)) return 'Today';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (DateFormatter.isSameDay(date, yesterday)) return 'Yesterday';
    return DateFormatter.formatFull(date);
  }
}

// ─── Date group ───────────────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  final String label;
  final List<TransactionModel> transactions;
  final void Function(TransactionModel) onEdit;
  final void Function(TransactionModel) onDelete;

  const _DateGroup({
    required this.label,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 10),
          child: Row(
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.textSecondary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
        ...transactions.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TxCard(
              transaction: t,
              onEdit: () => onEdit(t),
              onDelete: () => onDelete(t),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Transaction card ─────────────────────────────────────────────────────────

class _TxCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TxCard({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final accent = isIncome ? AppColors.income : AppColors.expense;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.expense,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Iconsax.trash, color: Colors.white, size: 16),
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete transaction?'),
            content: Text('Remove "${transaction.title}" permanently?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.expense,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _iconFor(transaction.category),
                color: accent,
                size: 20,
              ),
            ),
            const Gap(12),
            // Title + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.category,
                          style: AppTextStyles.caption.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(8),
            // Amount + edit
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatSigned(
                    transaction.amount,
                    isExpense: !isIncome,
                  ),
                  style: AppTextStyles.amountSmall.copyWith(color: accent),
                ),
                const Gap(4),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Iconsax.edit,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'food & drinks':
        return Iconsax.coffee;
      case 'shopping':
        return Iconsax.bag;
      case 'transport':
        return Iconsax.car;
      case 'housing':
        return Iconsax.home;
      case 'health':
        return Iconsax.health;
      case 'entertainment':
        return Iconsax.music;
      case 'education':
        return Iconsax.book;
      case 'salary':
        return Iconsax.money;
      case 'freelance':
        return Iconsax.briefcase;
      case 'investment':
        return Iconsax.chart;
      default:
        return Iconsax.wallet;
    }
  }
}

// ─── Filter chip (single unified style) ──────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}
