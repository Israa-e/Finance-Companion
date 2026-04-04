import 'package:equatable/equatable.dart';

// FIX: Added InsightsPeriod enum for time period filtering
enum InsightsPeriod {
  thisMonth,
  lastThreeMonths,
  lastSixMonths,
  allTime,
}

extension InsightsPeriodExt on InsightsPeriod {
  String get label {
    switch (this) {
      case InsightsPeriod.thisMonth:
        return 'This Month';
      case InsightsPeriod.lastThreeMonths:
        return 'Last 3 Months';
      case InsightsPeriod.lastSixMonths:
        return 'Last 6 Months';
      case InsightsPeriod.allTime:
        return 'All Time';
    }
  }
}

abstract class InsightsState extends Equatable {
  const InsightsState();
  @override
  List<Object?> get props => [];
}

class InsightsInitial extends InsightsState {}

class InsightsLoading extends InsightsState {}

class InsightsLoaded extends InsightsState {
  final Map<String, double> expensesByCategory;
  final Map<String, double> weeklyExpenses;
  final double thisMonthExpense;
  final double lastMonthExpense;
  final String topCategory;
  final double topCategoryAmount;
  final Map<String, double> monthlyTrend;
  final String mostFrequentCategory;
  final int mostFrequentCount;
  final InsightsPeriod activePeriod; // FIX: track which period is active

  const InsightsLoaded({
    required this.expensesByCategory,
    required this.weeklyExpenses,
    required this.thisMonthExpense,
    required this.lastMonthExpense,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.monthlyTrend,
    required this.mostFrequentCategory,
    required this.mostFrequentCount,
    this.activePeriod = InsightsPeriod.allTime,
  });

  double get monthlyChange => thisMonthExpense - lastMonthExpense;
  bool get isSpendingUp => monthlyChange > 0;

  @override
  List<Object?> get props => [
        expensesByCategory,
        weeklyExpenses,
        thisMonthExpense,
        lastMonthExpense,
        topCategory,
        topCategoryAmount,
        monthlyTrend,
        mostFrequentCategory,
        mostFrequentCount,
        activePeriod,
      ];
}

class InsightsError extends InsightsState {
  final String message;
  const InsightsError(this.message);
  @override
  List<Object?> get props => [message];
}