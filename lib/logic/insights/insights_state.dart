import 'package:equatable/equatable.dart';

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

  const InsightsLoaded({
    required this.expensesByCategory,
    required this.weeklyExpenses,
    required this.thisMonthExpense,
    required this.lastMonthExpense,
    required this.topCategory,
    required this.topCategoryAmount,
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
      ];
}

class InsightsError extends InsightsState {
  final String message;
  const InsightsError(this.message);
  @override
  List<Object?> get props => [message];
}