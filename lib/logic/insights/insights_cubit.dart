import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';
import 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final TransactionRepository _repo;

  InsightsCubit(this._repo) : super(InsightsInitial());

  Future<void> loadInsights() async {
    emit(InsightsLoading());
    try {
      final now = DateTime.now();
      final lastMonthDate = DateTime(now.year, now.month - 1, 1);

      final byCategory = await _repo.getExpensesByCategory();
      final weekly = await _repo.getWeeklyExpenses();
      final thisMonth = await _repo.getMonthlyExpense(now);
      final lastMonth = await _repo.getMonthlyExpense(lastMonthDate);

      // ── Top category by amount ─────────────────────────────────────
      String topCategory = '';
      double topAmount = 0;
      byCategory.forEach((cat, amount) {
        if (amount > topAmount) {
          topAmount = amount;
          topCategory = cat;
        }
      });

      // ── Monthly trend — last 6 months (oldest → newest) ────────────
      final monthlyTrend = <String, double>{};
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final label = DateFormat('MMM').format(month);
        monthlyTrend[label] = await _repo.getMonthlyExpense(month);
      }

      // ── Most frequent category (by transaction count) ──────────────
      final allTransactions = await _repo.getAll();
      final countMap = <String, int>{};
      for (final t in allTransactions.where(
        (t) => t.type == TransactionType.expense,
      )) {
        countMap[t.category] = (countMap[t.category] ?? 0) + 1;
      }
      String mostFrequentCategory = '';
      int mostFrequentCount = 0;
      countMap.forEach((cat, count) {
        if (count > mostFrequentCount) {
          mostFrequentCount = count;
          mostFrequentCategory = cat;
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
          monthlyTrend: monthlyTrend,
          mostFrequentCategory: mostFrequentCategory,
          mostFrequentCount: mostFrequentCount,
        ),
      );
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }
}
