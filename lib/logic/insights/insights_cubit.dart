import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transaction_repository.dart';
import 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final TransactionRepository _repo;

  InsightsCubit(this._repo) : super(InsightsInitial());

  Future<void> loadInsights() async {
    emit(InsightsLoading());
    try {
      final now = DateTime.now();

      // Safe previous month — handles January (month 1 → Dec of prior year)
      final lastMonthDate = DateTime(now.year, now.month - 1, 1);

      final byCategory = await _repo.getExpensesByCategory();
      final weekly = await _repo.getWeeklyExpenses();
      final thisMonth = await _repo.getMonthlyExpense(now);
      final lastMonth = await _repo.getMonthlyExpense(lastMonthDate);

      String topCategory = '';
      double topAmount = 0;
      byCategory.forEach((cat, amount) {
        if (amount > topAmount) {
          topAmount = amount;
          topCategory = cat;
        }
      });

      emit(
        InsightsLoaded(
          expensesByCategory: byCategory,
          weeklyExpenses: weekly,
          thisMonthExpense: thisMonth,
          lastMonthExpense: lastMonth,
          topCategory: topCategory,
          topCategoryAmount: topAmount,
        ),
      );
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }
}
