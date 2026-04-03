import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';

enum TransactionFilter { all, income, expense, today, thisWeek, thisMonth, lastMonth }

enum DateRangeFilter { today, thisWeek, thisMonth, lastMonth, all }

extension DateRangeFilterExt on DateRangeFilter {
  String get label {
    switch (this) {
      case DateRangeFilter.today:
        return 'Today';
      case DateRangeFilter.thisWeek:
        return 'This week';
      case DateRangeFilter.thisMonth:
        return 'This month';
      case DateRangeFilter.lastMonth:
        return 'Last month';
      case DateRangeFilter.all:
        return 'All time';
    }
  }

  /// Returns a [_DateRange] for filtering, or null if "all time".
  // ignore: library_private_types_in_public_api
  _DateRange? resolve() {
    final now = DateTime.now();
    switch (this) {
      case DateRangeFilter.today:
        final start = DateTime(now.year, now.month, now.day);
        return _DateRange(start, start.add(const Duration(days: 1)));
      case DateRangeFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        final s = DateTime(start.year, start.month, start.day);
        return _DateRange(s, now);
      case DateRangeFilter.thisMonth:
        return _DateRange(DateTime(now.year, now.month, 1), now);
      case DateRangeFilter.lastMonth:
        final first = DateTime(now.year, now.month - 1, 1);
        final last = DateTime(
          now.year,
          now.month,
          1,
        ).subtract(const Duration(milliseconds: 1));
        return _DateRange(first, last);
      case DateRangeFilter.all:
        return null;
    }
  }
}

class _DateRange {
  final DateTime start;
  final DateTime end;
  const _DateRange(this.start, this.end);
}

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

extension DateExt on DateTime {
  bool isWithinRange(DateRangeFilter rangeFilter) {
    final range = rangeFilter.resolve();
    if (range == null) return true;
    return !isBefore(range.start) && !isAfter(range.end);
  }
}

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final double initialBalance;

  // Search & Filter (Consolidated)
  final String searchQuery;
  final TransactionFilter activeFilter;

  // Form states (Consolidated)
  final TransactionType formType;
  final String formCategory;
  final double formAmount;
  final DateTime formDate;
  final String formTitle;
  final String formNote;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? formErrorMessage;

  const TransactionLoaded({
    required this.transactions,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    this.initialBalance = 0.0,
    this.searchQuery = '',
    this.activeFilter = TransactionFilter.all,
    this.formType = TransactionType.expense,
    this.formCategory = 'Food',
    this.formAmount = 0.0,
    required this.formDate,
    this.formTitle = '',
    this.formNote = '',
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.formErrorMessage,
  });

  TransactionLoaded copyWith({
    List<TransactionModel>? transactions,
    double? balance,
    double? totalIncome,
    double? totalExpense,
    double? initialBalance,
    String? searchQuery,
    TransactionFilter? activeFilter,
    TransactionType? formType,
    String? formCategory,
    double? formAmount,
    DateTime? formDate,
    String? formTitle,
    String? formNote,
    bool? isSubmitting,
    bool? submitSuccess,
    String? formErrorMessage,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      initialBalance: initialBalance ?? this.initialBalance,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      formType: formType ?? this.formType,
      formCategory: formCategory ?? this.formCategory,
      formAmount: formAmount ?? this.formAmount,
      formDate: formDate ?? this.formDate,
      formTitle: formTitle ?? this.formTitle,
      formNote: formNote ?? this.formNote,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      formErrorMessage: formErrorMessage,
    );
  }

  // Filtered list helper
  List<TransactionModel> get filteredTransactions {
    // Note: The UI now uses a separate set of filters (All, Income, Expense)
    // and groups by Date. We'll filter by Type and Search, and then group.
    
    return transactions.where((tx) {
      final matchesSearch = tx.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tx.category.toLowerCase().contains(searchQuery.toLowerCase());
      
      final type = activeFilter.type;
      bool matchesFilter = type == null || tx.type == type;
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  /// Groups the filtered transactions by date (Today, Yesterday, etc.)
  Map<String, List<TransactionModel>> get groupedTransactions {
    final filtered = filteredTransactions;
    final groups = <String, List<TransactionModel>>{};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final tx in filtered) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String key;
      
      if (txDate.isAtSameMomentAs(today)) {
        key = 'Today';
      } else if (txDate.isAtSameMomentAs(yesterday)) {
        key = 'Yesterday';
      } else {
        // Format as "MMM dd, yyyy" or similar
        key = '${_monthName(txDate.month)} ${txDate.day}, ${txDate.year}';
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(tx);
    }

    return groups;
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [
        transactions,
        balance,
        totalIncome,
        totalExpense,
        initialBalance,
        searchQuery,
        activeFilter,
        formType,
        formCategory,
        formAmount,
        formDate,
        formTitle,
        formNote,
        isSubmitting,
        submitSuccess,
        formErrorMessage,
      ];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}