import 'package:flutter/foundation.dart' show VoidCallback;
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

  /// Called after any mutation (add / update / delete) so that
  /// InsightsCubit and other listeners can refresh.
  VoidCallback? onMutated;

  TransactionCubit(this._repo) : super(TransactionInitial());

  void setUser(int userId, double initialBalance) {
    _userId = userId;
    _initialBalance = initialBalance;
  }

  void setInitialBalance(double balance) {
    _initialBalance = balance;
  }

  // ── Load ──────────────────────────────────────────────────────────────────

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
        formDate: DateTime.now(),
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  // ── Search & Filter ───────────────────────────────────────────────────────

  void updateSearchQuery(String query) {
    final current = state;
    if (current is TransactionLoaded) {
      emit(current.copyWith(searchQuery: query));
    }
  }

  void updateFilter(TransactionFilter filter) {
    final current = state;
    if (current is TransactionLoaded) {
      emit(current.copyWith(activeFilter: filter));
    }
  }

  // ── Form field updates ────────────────────────────────────────────────────

  void updateFormType(TransactionType type) {
    final current = state;
    if (current is TransactionLoaded) {
      final category =
          type == TransactionType.expense ? 'Food & Drinks' : 'Salary';
      emit(current.copyWith(formType: type, formCategory: category));
    }
  }

  void updateFormCategory(String category) {
    final current = state;
    if (current is TransactionLoaded) {
      emit(current.copyWith(formCategory: category));
    }
  }

  void updateFormAmount(double amount) {
    final current = state;
    if (current is TransactionLoaded) {
      emit(current.copyWith(formAmount: amount));
    }
  }

  void updateFormDate(DateTime date) {
    final current = state;
    if (current is TransactionLoaded) {
      emit(current.copyWith(formDate: date));
    }
  }

  void updateFormTitle(String title) {
    final current = state;
    if (current is TransactionLoaded) {
      emit(current.copyWith(formTitle: title));
    }
  }

  void updateFormNote(String note) {
    final current = state;
    if (current is TransactionLoaded) {
      emit(current.copyWith(formNote: note));
    }
  }

  // ── Submit (Add) ──────────────────────────────────────────────────────────

  Future<void> submitTransactionForm() async {
    final current = state;
    if (current is! TransactionLoaded) return;

    if (current.formTitle.trim().isEmpty || current.formAmount <= 0) {
      emit(current.copyWith(
          formErrorMessage: 'Please fill all required fields.'));
      return;
    }

    emit(current.copyWith(isSubmitting: true, formErrorMessage: null));
    try {
      final transaction = TransactionModel(
        id: _uuid.v4(),
        userId: _userId,
        amount: current.formAmount,
        type: current.formType,
        category: current.formCategory,
        date: current.formDate,
        title: current.formTitle.trim(),
        note: current.formNote.trim().isEmpty
            ? null
            : current.formNote.trim(),
        lastUpdated: DateTime.now(),
      );

      await _repo.add(transaction);

      final transactions = await _repo.getAll();
      final income = await _repo.getTotalIncome();
      final expense = await _repo.getTotalExpense();
      final balance = _initialBalance + income - expense;

      // FIX: emit fresh state — submitSuccess: true, form reset to defaults
      emit(TransactionLoaded(
        transactions: transactions,
        balance: balance,
        totalIncome: income,
        totalExpense: expense,
        initialBalance: _initialBalance,
        formDate: DateTime.now(),
        submitSuccess: true, // triggers pop in UI
        // All form fields intentionally left at defaults (empty)
      ));

      onMutated?.call();
    } catch (e) {
      emit(current.copyWith(
          isSubmitting: false, formErrorMessage: e.toString()));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _repo.update(transaction);
      await loadTransactions();
      onMutated?.call(); // FIX: was missing — insights won't refresh on edit
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteTransaction(String id) async {
    try {
      await _repo.delete(id);
      await loadTransactions();
      onMutated?.call();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  // ── Legacy helpers (kept for compatibility) ───────────────────────────────

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
        lastUpdated: DateTime.now(),
      );
      await _repo.add(transaction);
      await loadTransactions();
      onMutated?.call();
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}