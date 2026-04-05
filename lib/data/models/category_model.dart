import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final String type; // 'income' or 'expense'
  final int? userId;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
    this.userId,
    required this.createdAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconCode': iconCode,
        'colorValue': colorValue,
        'type': type,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'],
        name: map['name'],
        iconCode: map['iconCode'],
        colorValue: map['colorValue'],
        type: map['type'],
        userId: map['userId'],
        createdAt: DateTime.parse(map['createdAt']),
      );

  @override
  List<Object?> get props => [id, name, iconCode, colorValue, type, userId, createdAt];
}
