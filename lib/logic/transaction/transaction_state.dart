import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final double initialBalance;

  const TransactionLoaded({
    required this.transactions,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    this.initialBalance = 0.0,
  });

  @override
  List<Object?> get props =>
      [transactions, balance, totalIncome, totalExpense, initialBalance];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}