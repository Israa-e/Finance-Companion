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

  TransactionCubit(this._repo) : super(TransactionInitial());

  /// Called once after login/register with the authenticated user's data
  void setUser(int userId, double initialBalance) {
    _userId = userId;
    _initialBalance = initialBalance;
  }

  // Keep old method for backward compat (used in previous fix)
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
      emit(TransactionLoaded(
        transactions: transactions,
        balance: balance,
        totalIncome: income,
        totalExpense: expense,
        initialBalance: _initialBalance,
      ));
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
        userId: _userId,          // ← userId is now always set
        amount: amount,
        type: type,
        category: category,
        date: date,
        title: title,
        note: note,
      );
      await _repo.add(transaction);
      await loadTransactions();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _repo.update(transaction);
      await loadTransactions();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repo.delete(id);
      await loadTransactions();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  List<TransactionModel> getFiltered({
    TransactionType? type,
    String? category,
    String? searchQuery,
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
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q) ||
              (t.note?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return list;
  }
}