import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repo;
  final _uuid = const Uuid();

  double _initialBalance = 0.0;
  int _userId = 0;

  /// Optional callback invoked after every mutating operation
  /// (add / update / delete). Wire this to InsightsCubit.loadInsights()
  /// in AppNavigation so insights stay fresh without manual pull-to-refresh.
  VoidCallback? onMutated;

  TransactionCubit(this._repo) : super(TransactionInitial());

  void setUser(int userId, double initialBalance) {
    _userId = userId;
    _initialBalance = initialBalance;
  }

  void setInitialBalance(double balance) {
    _initialBalance = balance;
  }

  Future<void> loadTransactions() async {
    emit(TransactionLoading());
    try {
      final transactions = await _repo.getAll();
      final income = await _repo.getTotalIncome();
      final expense = await _repo.getTotalExpense();
      final balance = _initialBalance + income - expense;
      emit(
        TransactionLoaded(
          transactions: transactions,
          balance: balance,
          totalIncome: income,
          totalExpense: expense,
          initialBalance: _initialBalance,
        ),
      );
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    required String title,
    String? note,
  }) async {
    try {
      final transaction = TransactionModel(
        id: _uuid.v4(),
        userId: _userId,
        amount: amount,
        type: type,
        category: category,
        date: date,
        title: title,
        note: note,
      );
      await _repo.add(transaction);
      await loadTransactions();
      onMutated?.call();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _repo.update(transaction);
      await loadTransactions();
      onMutated?.call();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repo.delete(id);
      await loadTransactions();
      onMutated?.call();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  List<TransactionModel> getFiltered({
    TransactionType? type,
    String? category,
    String? searchQuery,
    DateRangeFilter? dateRange,
  }) {
    final state = this.state;
    if (state is! TransactionLoaded) return [];
    var list = state.transactions;

    if (type != null) list = list.where((t) => t.type == type).toList();
    if (category != null) {
      list = list.where((t) => t.category == category).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                t.category.toLowerCase().contains(q) ||
                (t.note?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    if (dateRange != null) {
      final range = dateRange.resolve();
      if (range != null) {
        list = list
            .where(
              (t) =>
                  !t.date.isBefore(range.start) && !t.date.isAfter(range.end),
            )
            .toList();
      }
    }

    return list;
  }
}

// ─── Date range filter ────────────────────────────────────────────────────────

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

// Alias so we don't need to import Flutter just for the typedef.
typedef VoidCallback = void Function();
