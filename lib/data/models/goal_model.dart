import 'package:equatable/equatable.dart';

enum GoalStatus { active, completed, failed }

class GoalModel extends Equatable {
  final String id;
  final int userId;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime startDate;
  final DateTime endDate;
  final GoalStatus status;
  final String? emoji;

  const GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.emoji,
  });

  double get progressPercent =>
      (savedAmount / targetAmount).clamp(0.0, 1.0);
  double get remainingAmount =>
      (targetAmount - savedAmount).clamp(0.0, double.infinity);
  bool get isCompleted => savedAmount >= targetAmount;
  int get daysRemaining =>
      endDate.difference(DateTime.now()).inDays.clamp(0, 999);

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.name,
        'emoji': emoji,
      };

  factory GoalModel.fromMap(Map<String, dynamic> map) => GoalModel(
        id: map['id'],
        userId: map['userId'],
        title: map['title'],
        targetAmount: (map['targetAmount'] as num).toDouble(),
        savedAmount: (map['savedAmount'] as num).toDouble(),
        startDate: DateTime.parse(map['startDate']),
        endDate: DateTime.parse(map['endDate']),
        status: GoalStatus.values.byName(map['status']),
        emoji: map['emoji'],
      );

  GoalModel copyWith({
    String? id,
    int? userId,
    String? title,
    double? targetAmount,
    double? savedAmount,
    DateTime? startDate,
    DateTime? endDate,
    GoalStatus? status,
    String? emoji,
  }) =>
      GoalModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        targetAmount: targetAmount ?? this.targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        emoji: emoji ?? this.emoji,
      );

  @override
  List<Object?> get props =>
      [id, title, targetAmount, savedAmount, startDate, endDate, status];
}