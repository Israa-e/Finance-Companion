import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';
import 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final TransactionRepository _repo;

  InsightsCubit(this._repo) : super(InsightsInitial());

  Future<void> loadInsights({InsightsPeriod period = InsightsPeriod.allTime}) async {
    emit(InsightsLoading());
    try {
      final now = DateTime.now();
      final lastMonthDate = DateTime(now.year, now.month - 1, 1);

      // FIX: apply period filter to category and weekly data
      final allTransactions = await _repo.getAll();
      final filtered = _filterByPeriod(allTransactions, period, now);

      // Expenses by category (filtered)
      final Map<String, double> byCategory = {};
      for (final t in filtered.where((t) => t.type == TransactionType.expense)) {
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      }

      // Weekly expenses from filtered data
      final Map<String, double> weekly = {};
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final start = DateTime(day.year, day.month, day.day);
        final end = start.add(const Duration(days: 1));
        final key = '${day.day}/${day.month}';
        weekly[key] = filtered
            .where((t) => t.type == TransactionType.expense)
            .where(
              (t) =>
                  t.date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
                  t.date.isBefore(end),
            )
            .fold(0.0, (sum, t) => sum + t.amount);
      }

      // Month-over-month uses all-time data (not filtered) for context
      final thisMonth = await _repo.getMonthlyExpense(now);
      final lastMonth = await _repo.getMonthlyExpense(lastMonthDate);

      // Top category
      String topCategory = '';
      double topAmount = 0;
      byCategory.forEach((cat, amount) {
        if (amount > topAmount) {
          topAmount = amount;
          topCategory = cat;
        }
      });

      // Monthly trend — last 6 months (all-time data for accuracy)
      final monthlyTrend = <String, double>{};
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final label = DateFormat('MMM').format(month);
        monthlyTrend[label] = await _repo.getMonthlyExpense(month);
      }

      // Most frequent category
      final countMap = <String, int>{};
      for (final t in filtered.where((t) => t.type == TransactionType.expense)) {
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

      emit(InsightsLoaded(
        expensesByCategory: byCategory,
        weeklyExpenses: weekly,
        thisMonthExpense: thisMonth,
        lastMonthExpense: lastMonth,
        topCategory: topCategory,
        topCategoryAmount: topAmount,
        monthlyTrend: monthlyTrend,
        mostFrequentCategory: mostFrequentCategory,
        mostFrequentCount: mostFrequentCount,
        activePeriod: period,
        transactions: filtered, // ADDED
      ));
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }

  /// Filters transactions by the selected period.
  List<TransactionModel> _filterByPeriod(
    List<TransactionModel> all,
    InsightsPeriod period,
    DateTime now,
  ) {
    switch (period) {
      case InsightsPeriod.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        return all.where((t) => t.date.isAfter(start)).toList();
      case InsightsPeriod.lastThreeMonths:
        final start = DateTime(now.year, now.month - 2, 1);
        return all.where((t) => t.date.isAfter(start)).toList();
      case InsightsPeriod.lastSixMonths:
        final start = DateTime(now.year, now.month - 5, 1);
        return all.where((t) => t.date.isAfter(start)).toList();
      case InsightsPeriod.allTime:
        return all;
    }
  }

  void changePeriod(InsightsPeriod period) {
    loadInsights(period: period);
  }
}