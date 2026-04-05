import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';
import 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final TransactionRepository _repo;
  final double _userBudget;

  InsightsCubit(this._repo, {double userMonthlyBudget = 2000.0})
      : _userBudget = userMonthlyBudget,
        super(InsightsInitial());

  Future<void> loadInsights(
      {InsightsPeriod period = InsightsPeriod.allTime}) async {
    emit(InsightsLoading());
    try {
      final now = DateTime.now();

      // P1 FIX: single getAll() call instead of multiple sequential repo calls
      final allTransactions = await _repo.getAll();
      final filtered = _filterByPeriod(allTransactions, period, now);

      final lastMonthDate = DateTime(now.year, now.month - 1, 1);

      // Dynamically determine trend months based on period
      int trendMonths = 6;
      switch (period) {
        case InsightsPeriod.thisMonth:
          trendMonths = 1;
          break;
        case InsightsPeriod.lastThreeMonths:
          trendMonths = 3;
          break;
        case InsightsPeriod.lastSixMonths:
          trendMonths = 6;
          break;
        case InsightsPeriod.thisYear:
          trendMonths = now.month;
          break;
        case InsightsPeriod.allTime:
          trendMonths = 12;
          break;
      }

      final monthlyFutures = <Future<double>>[];
      final monthLabels = <String>[];
      for (int i = trendMonths - 1; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        monthLabels.add(DateFormat('MMM').format(month));
        monthlyFutures.add(_computeMonthlyExpense(allTransactions, month));
      }

      // thisMonth + lastMonth + trend values — all in parallel
      final results = await Future.wait([
        _computeMonthlyExpense(allTransactions, now),
        _computeMonthlyExpense(allTransactions, lastMonthDate),
        ...monthlyFutures,
      ]);

      final thisMonth = results[0];
      final lastMonth = results[1];
      final monthlyTrend = <String, double>{};
      for (int i = 0; i < monthLabels.length; i++) {
        monthlyTrend[monthLabels[i]] = results[2 + i];
      }

      // Expenses by category (from filtered set)
      final Map<String, double> byCategory = {};
      for (final t
          in filtered.where((t) => t.type == TransactionType.expense)) {
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
            .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
            .fold(0.0, (sum, t) => sum + t.amount);
      }

      // Top category
      String topCategory = '';
      double topAmount = 0;
      byCategory.forEach((cat, amount) {
        if (amount > topAmount) {
          topAmount = amount;
          topCategory = cat;
        }
      });

      // Most frequent category
      final countMap = <String, int>{};
      for (final t
          in filtered.where((t) => t.type == TransactionType.expense)) {
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

      // Predictive Analytics (Burn Rate)
      final dayOfMonth = now.day;
      final dailyBurnRate = dayOfMonth > 0 ? thisMonth / dayOfMonth : 0.0;
      final monthlyBudget = _userBudget;
      DateTime? predictedBreachDate;
      if (dailyBurnRate > 0 && thisMonth < monthlyBudget) {
        final remainingBudget = monthlyBudget - thisMonth;
        final daysLeft = (remainingBudget / dailyBurnRate).floor();
        predictedBreachDate = now.add(Duration(days: daysLeft));
      }

      // Weekday vs weekend spending variance
      final weekdayExpenses = filtered.where((t) =>
          t.type == TransactionType.expense &&
          t.date.weekday >= 1 &&
          t.date.weekday <= 5);
      final weekendExpenses = filtered.where((t) =>
          t.type == TransactionType.expense &&
          (t.date.weekday == 6 || t.date.weekday == 7));

      final weekdayAvg = weekdayExpenses.isEmpty
          ? 0.0
          : weekdayExpenses.fold(0.0, (sum, t) => sum + t.amount) /
              weekdayExpenses.length;
      final weekendAvg = weekendExpenses.isEmpty
          ? 0.0
          : weekendExpenses.fold(0.0, (sum, t) => sum + t.amount) /
              weekendExpenses.length;

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
        transactions: filtered,
        dailyBurnRate: dailyBurnRate,
        predictedBreachDate: predictedBreachDate,
        weekdayAverage: weekdayAvg,
        weekendAverage: weekendAvg,
      ));
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }

  /// Compute monthly expense synchronously from an already-fetched list.
  Future<double> _computeMonthlyExpense(
    List<TransactionModel> all,
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return all
        .where((t) => t.type == TransactionType.expense)
        .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// P2 FIX: use !isBefore(start) instead of isAfter(start) to include
  /// transactions on the exact first moment of the period.
  List<TransactionModel> _filterByPeriod(
    List<TransactionModel> all,
    InsightsPeriod period,
    DateTime now,
  ) {
    switch (period) {
      case InsightsPeriod.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        return all.where((t) => !t.date.isBefore(start)).toList();
      case InsightsPeriod.lastThreeMonths:
        final start = DateTime(now.year, now.month - 2, 1);
        return all.where((t) => !t.date.isBefore(start)).toList();
      case InsightsPeriod.lastSixMonths:
        final start = DateTime(now.year, now.month - 5, 1);
        return all.where((t) => !t.date.isBefore(start)).toList();
      case InsightsPeriod.thisYear:
        final start = DateTime(now.year, 1, 1);
        return all.where((t) => !t.date.isBefore(start)).toList();
      case InsightsPeriod.allTime:
        return all;
    }
  }

  void changePeriod(InsightsPeriod period) {
    loadInsights(period: period);
  }
}
