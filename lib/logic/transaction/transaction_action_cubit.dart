import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/services/alert_service.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionActionState extends Equatable {
  const TransactionActionState();
  @override
  List<Object?> get props => [];
}

class TransactionActionInitial extends TransactionActionState {}
class TransactionActionLoading extends TransactionActionState {}
class TransactionActionSuccess extends TransactionActionState {}
class TransactionActionError extends TransactionActionState {
  final String message;
  const TransactionActionError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionActionCubit extends Cubit<TransactionActionState> {
  final TransactionRepository _repo;
  final AlertService? _alertService;

  // Parameters for alerts
  double _monthlyBudget = 0.0;
  double _warningThreshold = 0.8;
  double _criticalThreshold = 1.0;

  TransactionActionCubit(this._repo, [this._alertService]) : super(TransactionActionInitial());

  void setAlertParams({
    required double monthlyBudget,
    double warningThreshold = 0.8,
    double criticalThreshold = 1.0,
  }) {
    _monthlyBudget = monthlyBudget;
    _warningThreshold = warningThreshold;
    _criticalThreshold = criticalThreshold;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    emit(TransactionActionLoading());
    try {
      await _repo.add(transaction);
      await _triggerAlerts();
      emit(TransactionActionSuccess());
    } catch (e) {
      emit(TransactionActionError(e.toString()));
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    emit(TransactionActionLoading());
    try {
      await _repo.update(transaction);
      await _triggerAlerts();
      emit(TransactionActionSuccess());
    } catch (e) {
      emit(TransactionActionError(e.toString()));
    }
  }

  Future<void> deleteTransaction(String id) async {
    emit(TransactionActionLoading());
    try {
      await _repo.delete(id);
      await _triggerAlerts();
      emit(TransactionActionSuccess());
    } catch (e) {
      emit(TransactionActionError(e.toString()));
    }
  }

  Future<void> _triggerAlerts() async {
    if (_alertService == null) return;
    try {
      final transactions = await _repo.getAll();
      await _alertService!.checkBudgetAlerts(
        transactions: transactions,
        monthlyBudget: _monthlyBudget,
        warningThreshold: _warningThreshold,
        criticalThreshold: _criticalThreshold,
      );
    } catch (_) {}
  }
}
