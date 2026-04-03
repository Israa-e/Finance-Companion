import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/goal_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import 'goal_state.dart';

class GoalCubit extends Cubit<GoalState> {
  final GoalRepository _repo;
  final TransactionRepository _txRepo;
  final _uuid = const Uuid();
  int _userId = 0;

  GoalCubit(this._repo, this._txRepo) : super(GoalInitial());

  void setUser(int userId) {
    _userId = userId;
  }

  Future<void> loadGoals() async {
    emit(GoalLoading());
    try {
      final goals = await _repo.getAll(_userId);
      final active = await _repo.getActive(_userId);
      emit(GoalLoaded(goals: goals, activeGoals: active));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  // --- Goal Form (Consolidated) ---

  void updateFormTitle(String title) {
    final current = state;
    if (current is GoalLoaded) emit(current.copyWith(formTitle: title));
  }

  void updateFormAmount(double amount) {
    final current = state;
    if (current is GoalLoaded) emit(current.copyWith(formAmount: amount));
  }

  void updateFormDate(DateTime date) {
    final current = state;
    if (current is GoalLoaded) emit(current.copyWith(formEndDate: date));
  }

  void updateFormEmoji(String emoji) {
    final current = state;
    if (current is GoalLoaded) emit(current.copyWith(formEmoji: emoji));
  }

  Future<void> submitGoalForm() async {
    final current = state;
    if (current is! GoalLoaded) return;

    if (current.formTitle.trim().isEmpty || current.formAmount <= 0) {
      emit(current.copyWith(
        formErrorMessage: 'Please fill all fields correctly.',
      ));
      return;
    }

    emit(current.copyWith(isSubmitting: true, formErrorMessage: null));
    try {
      final goal = GoalModel(
        id: _uuid.v4(),
        userId: _userId,
        title: current.formTitle.trim(),
        targetAmount: current.formAmount,
        savedAmount: 0,
        startDate: DateTime.now(),
        endDate: current.formEndDate ?? DateTime.now().add(const Duration(days: 30)),
        status: GoalStatus.active,
        emoji: current.formEmoji,
      );
      await _repo.add(goal);
      
      // Reset form on success and reload
      final goals = await _repo.getAll(_userId);
      final active = await _repo.getActive(_userId);
      emit(GoalLoaded(
        goals: goals,
        activeGoals: active,
        submitSuccess: true,
      ));
    } catch (e) {
      emit(current.copyWith(isSubmitting: false, formErrorMessage: e.toString()));
    }
  }

  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required DateTime endDate,
    String? emoji,
  }) async {
    try {
      final goal = GoalModel(
        id: _uuid.v4(),
        userId: _userId,
        title: title,
        targetAmount: targetAmount,
        savedAmount: 0,
        startDate: DateTime.now(),
        endDate: endDate,
        status: GoalStatus.active,
        emoji: emoji,
      );
      await _repo.add(goal);
      await loadGoals();
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> addToSavings(
    String id,
    double amount, {
    double? availableBalance,
  }) async {
    final currentState = state;
    if (currentState is! GoalLoaded) return;

    try {
      final goal = currentState.goals.firstWhere((goal) => goal.id == id);
      if (amount <= 0) {
        emit(const GoalError('Amount must be greater than zero.'));
        // Reset back to loaded so the UI recovers without a full reload.
        emit(currentState);
        return;
      }
      if (amount > goal.remainingAmount) {
        emit(const GoalError('Amount exceeds remaining goal total.'));
        emit(currentState);
        return;
      }
      if (availableBalance != null && amount > availableBalance) {
        emit(const GoalError('Not enough available balance for this goal.'));
        emit(currentState);
        return;
      }

      await _repo.addToSavings(id, amount);
      await loadGoals();
    } catch (e) {
      emit(GoalError(e.toString()));
      // Recover to the last known-good loaded state.
      // if (currentState is GoalLoaded) emit(currentState);
    }
  }

  /// Deletes the goal and creates a refund income transaction for any
  /// amount already saved towards it, so the balance is restored.
  Future<void> deleteGoal(String id) async {
    final currentState = state;
    try {
      final savedAmount = await _repo.delete(id);

      // If money was locked into this goal, refund it as an income entry.
      if (savedAmount > 0) {
        final goalTitle = currentState is GoalLoaded
            ? currentState.goals
                  .firstWhere(
                    (g) => g.id == id,
                    orElse: () => GoalModel(
                      id: id,
                      userId: _userId,
                      title: 'Deleted Goal',
                      targetAmount: 0,
                      savedAmount: 0,
                      startDate: DateTime.now(),
                      endDate: DateTime.now(),
                      status: GoalStatus.active,
                    ),
                  )
                  .title
            : 'Deleted Goal';

        await _txRepo.add(
          TransactionModel(
            id: _uuid.v4(),
            userId: _userId,
            amount: savedAmount,
            type: TransactionType.income,
            category: 'Other',
            date: DateTime.now(),
            title: 'Refund: $goalTitle',
            note: 'Automatically refunded when goal was deleted.',
          ),
        );
      }

      await loadGoals();
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }
}
