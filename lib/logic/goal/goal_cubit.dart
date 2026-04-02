import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/goal_model.dart';
import '../../data/repositories/goal_repository.dart';
import 'goal_state.dart';

class GoalCubit extends Cubit<GoalState> {
  final GoalRepository _repo;
  final _uuid = const Uuid();
  int _userId = 0;

  GoalCubit(this._repo) : super(GoalInitial());

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

  Future<void> addToSavings(String id, double amount) async {
    try {
      await _repo.addToSavings(id, amount);
      await loadGoals();
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _repo.delete(id);
      await loadGoals();
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }
}
