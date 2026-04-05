import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/transaction_view_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/transaction_view_repository.dart';
import 'transaction_state.dart';

class TransactionFilterState extends Equatable {
  final List<TransactionModel> transactions;
  final List<TransactionView> savedViews;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final double initialBalance;
  
  // Filtering properties
  final String searchQuery;
  final TransactionFilter activeFilter;
  final List<String> selectedCategories;
  final CustomDateRange? customDateRange;
  
  final bool isLoading;
  final String? errorMessage;

  const TransactionFilterState({
    this.transactions = const [],
    this.savedViews = const [],
    this.balance = 0.0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.initialBalance = 0.0,
    this.searchQuery = '',
    this.activeFilter = TransactionFilter.all,
    this.selectedCategories = const [],
    this.customDateRange,
    this.isLoading = false,
    this.errorMessage,
  });

  TransactionFilterState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionView>? savedViews,
    double? balance,
    double? totalIncome,
    double? totalExpense,
    double? initialBalance,
    String? searchQuery,
    TransactionFilter? activeFilter,
    List<String>? selectedCategories,
    CustomDateRange? customDateRange,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TransactionFilterState(
      transactions: transactions ?? this.transactions,
      savedViews: savedViews ?? this.savedViews,
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      initialBalance: initialBalance ?? this.initialBalance,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      customDateRange: customDateRange ?? this.customDateRange,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Integrated filtering logic
  List<TransactionModel> get filteredTransactions {
    return transactions.where((tx) {
      final q = searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          tx.title.toLowerCase().contains(q) ||
          tx.category.toLowerCase().contains(q) ||
          (tx.note?.toLowerCase().contains(q) ?? false);

      final typeFilter = activeFilter.type;
      final matchesType = typeFilter == null || tx.type == typeFilter;

      final matchesCategory = selectedCategories.isEmpty ||
          selectedCategories.contains(tx.category);

      bool matchesDate = true;
      if (customDateRange != null) {
        matchesDate = !tx.date.isBefore(customDateRange!.start) &&
            !tx.date.isAfter(customDateRange!.end);
      } else {
        final rangeFilter = activeFilter.dateRange;
        if (rangeFilter != null) {
          final range = rangeFilter.resolve();
          if (range != null) {
            matchesDate = !tx.date.isBefore(range.start) && !tx.date.isAfter(range.end);
          }
        }
      }
      return matchesSearch && matchesType && matchesCategory && matchesDate;
    }).toList();
  }

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
        key = '${_monthName(txDate.month)} ${txDate.day}, ${txDate.year}';
      }
      groups.putIfAbsent(key, () => []).add(tx);
    }
    return groups;
  }

  String _monthName(int month) => [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][month - 1];

  @override
  List<Object?> get props => [
    transactions, savedViews, balance, totalIncome, totalExpense,
    initialBalance, searchQuery, activeFilter, selectedCategories,
    customDateRange, isLoading, errorMessage
  ];
}

class TransactionFilterCubit extends Cubit<TransactionFilterState> {
  final TransactionRepository _repo;
  final TransactionViewRepository _viewRepo;
  int _userId = 0;

  TransactionFilterCubit(this._repo, this._viewRepo) : super(const TransactionFilterState());

  void setUser(int userId, double initialBalance) {
    _userId = userId;
    emit(state.copyWith(initialBalance: initialBalance));
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactions = await _repo.getAll();
      final savedViews = await _viewRepo.getAll(_userId);
      
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      final expense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      final balance = state.initialBalance + income - expense;

      emit(state.copyWith(
        transactions: transactions,
        savedViews: savedViews,
        balance: balance,
        totalIncome: income,
        totalExpense: expense,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void updateSearchQuery(String query) => emit(state.copyWith(searchQuery: query));
  void updateFilter(TransactionFilter filter) => emit(state.copyWith(activeFilter: filter));
  void updateSelectedCategories(List<String> categories) => emit(state.copyWith(selectedCategories: categories));
  void updateCustomDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      emit(state.copyWith(customDateRange: null));
    } else {
      final s = DateTime(start.year, start.month, start.day);
      final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
      emit(state.copyWith(customDateRange: CustomDateRange(s, e)));
    }
  }
  void resetFilters() => emit(state.copyWith(
    activeFilter: TransactionFilter.all,
    selectedCategories: const [],
    customDateRange: null,
    searchQuery: '',
  ));

  Future<void> saveCurrentView(String name) async {
    final view = TransactionView(
      id: DateTime.now().toIso8601String(), // simplistic id for now
      userId: _userId,
      name: name,
      filter: state.activeFilter,
      searchQuery: state.searchQuery,
      selectedCategories: state.selectedCategories,
      createdAt: DateTime.now(),
    );
    try {
      await _viewRepo.add(view);
      await load();
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to save: $e"));
    }
  }

  void applyView(TransactionView view) => emit(state.copyWith(
    activeFilter: view.filter,
    searchQuery: view.searchQuery,
    selectedCategories: view.selectedCategories ?? const [],
    customDateRange: null,
  ));

  Future<void> deleteView(String id) async {
    try {
      await _viewRepo.delete(id);
      await load();
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to delete: $e"));
    }
  }
}
