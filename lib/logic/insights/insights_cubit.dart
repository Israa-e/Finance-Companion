import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transaction_repository.dart';
import 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final TransactionRepository _repo;

  InsightsCubit(this._repo) : super(InsightsInitial());

  Future<void> loadInsights() async {
    emit(InsightsLoading());
    try {
      final byCategory = await _repo.getExpensesByCategory();
      final weekly = await _repo.getWeeklyExpenses();
      final thisMonth = await _repo.getMonthlyExpense(DateTime.now());
      final lastMonth = await _repo.getMonthlyExpense(
        DateTime(DateTime.now().year, DateTime.now().month - 1),
      );

      String topCategory = '';
      double topAmount = 0;
      byCategory.forEach((cat, amount) {
        if (amount > topAmount) {
          topAmount = amount;
          topCategory = cat;
        }
      });

      emit(InsightsLoaded(
        expensesByCategory: byCategory,
        weeklyExpenses: weekly,
        thisMonthExpense: thisMonth,
        lastMonthExpense: lastMonth,
        topCategory: topCategory,
        topCategoryAmount: topAmount,
      ));
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }
}