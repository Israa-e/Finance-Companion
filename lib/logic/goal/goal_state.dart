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

  // Form states (Consolidated)
  final String formTitle;
  final double formAmount;
  final DateTime? formEndDate;
  final String formEmoji;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? formErrorMessage;

  const GoalLoaded({
    required this.goals,
    required this.activeGoals,
    this.formTitle = '',
    this.formAmount = 0.0,
    this.formEndDate,
    this.formEmoji = '🎯',
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.formErrorMessage,
  });

  GoalLoaded copyWith({
    List<GoalModel>? goals,
    List<GoalModel>? activeGoals,
    String? formTitle,
    double? formAmount,
    DateTime? formEndDate,
    String? formEmoji,
    bool? isSubmitting,
    bool? submitSuccess,
    String? formErrorMessage,
  }) {
    return GoalLoaded(
      goals: goals ?? this.goals,
      activeGoals: activeGoals ?? this.activeGoals,
      formTitle: formTitle ?? this.formTitle,
      formAmount: formAmount ?? this.formAmount,
      formEndDate: formEndDate ?? this.formEndDate,
      formEmoji: formEmoji ?? this.formEmoji,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      formErrorMessage: formErrorMessage,
    );
  }

  double get totalLocked =>
      goals.fold(0.0, (sum, goal) => sum + goal.savedAmount);

  double get totalRemaining =>
      goals.fold(0.0, (sum, goal) => sum + goal.remainingAmount);

  @override
  List<Object?> get props => [
        goals,
        activeGoals,
        formTitle,
        formAmount,
        formEndDate,
        formEmoji,
        isSubmitting,
        submitSuccess,
        formErrorMessage,
      ];
}

class GoalError extends GoalState {
  final String message;
  const GoalError(this.message);
  @override
  List<Object?> get props => [message];
}