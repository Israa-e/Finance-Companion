import 'package:equatable/equatable.dart';

enum RecurringFrequency { daily, weekly, monthly }

class RecurringTransactionModel extends Equatable {
  final String id;
  final int userId;
  final String title;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String? note;
  final RecurringFrequency frequency;
  final DateTime nextDate;
  final DateTime? lastApplied;
  final bool isActive;
  final DateTime createdAt;

  const RecurringTransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.frequency,
    required this.nextDate,
    this.lastApplied,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'note': note,
        'frequency': frequency.name,
        'nextDate': nextDate.toIso8601String(),
        'lastApplied': lastApplied?.toIso8601String(),
        'isActive': isActive ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) =>
      RecurringTransactionModel(
        id: map['id'],
        userId: map['userId'],
        title: map['title'],
        amount: (map['amount'] as num).toDouble(),
        type: map['type'],
        category: map['category'],
        note: map['note'],
        frequency: RecurringFrequency.values.byName(map['frequency']),
        nextDate: DateTime.parse(map['nextDate']),
        lastApplied: map['lastApplied'] != null
            ? DateTime.parse(map['lastApplied'])
            : null,
        isActive: map['isActive'] == 1,
        createdAt: DateTime.parse(map['createdAt']),
      );

  RecurringTransactionModel copyWith({
    String? id,
    int? userId,
    String? title,
    double? amount,
    String? type,
    String? category,
    String? note,
    RecurringFrequency? frequency,
    DateTime? nextDate,
    DateTime? lastApplied,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      nextDate: nextDate ?? this.nextDate,
      lastApplied: lastApplied ?? this.lastApplied,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        amount,
        type,
        category,
        note,
        frequency,
        nextDate,
        lastApplied,
        isActive,
        createdAt
      ];
}
