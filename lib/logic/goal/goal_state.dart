import 'package:equatable/equatable.dart';
import '../../data/models/goal_model.dart';

abstract class GoalState extends Equatable {
  const GoalState();
  @override
  List<Object?> get props => [];
}

class GoalInitial extends GoalState {}
class GoalLoading extends GoalState {}

class GoalLoaded extends GoalState {
  final List<GoalModel> goals;
  final List<GoalModel> activeGoals;

  const GoalLoaded({
    required this.goals,
    required this.activeGoals,
  });

  double get totalLocked =>
      goals.fold(0.0, (sum, goal) => sum + goal.savedAmount);

  double get totalRemaining =>
      goals.fold(0.0, (sum, goal) => sum + goal.remainingAmount);

  @override
  List<Object?> get props => [goals, activeGoals];
}

class GoalError extends GoalState {
  final String message;
  const GoalError(this.message);
  @override
  List<Object?> get props => [message];
}