import 'package:equatable/equatable.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import '../../data/models/transaction_model.dart';

enum TransactionFilter { all, income, expense, today, thisWeek, thisMonth, lastMonth }

extension FilterExt on TransactionFilter {
  String get label {
    switch (this) {
      case TransactionFilter.all:
        return 'All';
      case TransactionFilter.income:
        return 'Income';
      case TransactionFilter.expense:
        return 'Expense';
      case TransactionFilter.today:
        return 'Today';
      case TransactionFilter.thisWeek:
        return 'This week';
      case TransactionFilter.thisMonth:
        return 'This month';
      case TransactionFilter.lastMonth:
        return 'Last month';
    }
  }

  TransactionType? get type {
    if (this == TransactionFilter.income) return TransactionType.income;
    if (this == TransactionFilter.expense) return TransactionType.expense;
    return null;
  }

  DateRangeFilter? get dateRange {
    switch (this) {
      case TransactionFilter.today:
        return DateRangeFilter.today;
      case TransactionFilter.thisWeek:
        return DateRangeFilter.thisWeek;
      case TransactionFilter.thisMonth:
        return DateRangeFilter.thisMonth;
      case TransactionFilter.lastMonth:
        return DateRangeFilter.lastMonth;
      default:
        return null;
    }
  }
}

class TransactionsSearchState extends Equatable {
  final TransactionFilter activeFilter;
  final String searchQuery;

  const TransactionsSearchState({
    this.activeFilter = TransactionFilter.all,
    this.searchQuery = '',
  });

  TransactionsSearchState copyWith({
    TransactionFilter? activeFilter,
    String? searchQuery,
  }) {
    return TransactionsSearchState(
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [activeFilter, searchQuery];
}
