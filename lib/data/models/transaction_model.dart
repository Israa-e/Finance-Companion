import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class TransactionModel extends Equatable {
  final String id;
  final int userId;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String title;
  final String? note;
  final DateTime lastUpdated;
  final bool isSynced;
  /// Soft-delete flag: true means this record is pending deletion on Firestore.
  /// Local reads always filter out isDeleted=true records.
  final bool isDeleted;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.title,
    this.note,
    required this.lastUpdated,
    this.isSynced = true,
    this.isDeleted = false,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'type': type.name,
        'category': category,
        'date': date.toIso8601String(),
        'title': title,
        'note': note,
        'lastUpdated': lastUpdated.toIso8601String(),
        'isSynced': isSynced ? 1 : 0,
        'isDeleted': isDeleted ? 1 : 0,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
      TransactionModel(
        id: map['id'],
        userId: map['userId'] as int,
        amount: (map['amount'] as num).toDouble(),
        type: TransactionType.values.byName(map['type']),
        category: map['category'],
        date: DateTime.parse(map['date']),
        title: map['title'],
        note: map['note'],
        lastUpdated: map['lastUpdated'] != null && map['lastUpdated'] != ""
            ? DateTime.parse(map['lastUpdated'])
            : DateTime.now(),
        isSynced: (map['isSynced'] as int?) == 1,
        isDeleted: (map['isDeleted'] as int?) == 1,
      );

  TransactionModel copyWith({
    String? id,
    int? userId,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? title,
    String? note,
    DateTime? lastUpdated,
    bool? isSynced,
    bool? isDeleted,
  }) =>
      TransactionModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        category: category ?? this.category,
        date: date ?? this.date,
        title: title ?? this.title,
        note: note ?? this.note,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  @override
  List<Object?> get props =>
      [id, userId, amount, type, category, date, title, note, lastUpdated, isSynced, isDeleted];
}