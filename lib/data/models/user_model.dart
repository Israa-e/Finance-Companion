import 'dart:convert';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final double initialBalance;
  final double monthlyBudget;
  final String currency;
  final String? imagePath;
  final DateTime createdAt;
  
  // New: Threshold configuration for budget alerts
  final double warningThreshold;  // e.g. 0.8 for 80%
  final double criticalThreshold; // e.g. 1.0 for 100%

  // New: Category-specific budgets (Category Name -> Budget Amount)
  final Map<String, double> categoryBudgets;

  // New: Security preference
  final bool biometricEnabled;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.initialBalance,
    this.monthlyBudget = 0.0,
    this.currency = 'USD',
    this.imagePath,
    required this.createdAt,
    this.warningThreshold = 0.8,
    this.criticalThreshold = 1.0,
    this.categoryBudgets = const {},
    this.biometricEnabled = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'initialBalance': initialBalance,
        'monthlyBudget': monthlyBudget,
        'currency': currency,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
        'warningThreshold': warningThreshold,
        'criticalThreshold': criticalThreshold,
        'categoryBudgets': jsonEncode(categoryBudgets),
        'biometricEnabled': biometricEnabled ? 1 : 0,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        passwordHash: map['passwordHash'],
        initialBalance: (map['initialBalance'] as num).toDouble(),
        monthlyBudget: (map['monthlyBudget'] as num?)?.toDouble() ?? 0.0,
        currency: map['currency'] as String? ?? 'USD',
        imagePath: map['imagePath'],
        createdAt: DateTime.parse(map['createdAt']),
        warningThreshold: (map['warningThreshold'] as num?)?.toDouble() ?? 0.8,
        criticalThreshold: (map['criticalThreshold'] as num?)?.toDouble() ?? 1.0,
        categoryBudgets: map['categoryBudgets'] != null
            ? Map<String, double>.from(jsonDecode(map['categoryBudgets'] as String)
                .map((k, v) => MapEntry(k, (v as num).toDouble())))
            : const {},
        biometricEnabled: (map['biometricEnabled'] as int?) == 1,
      );

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    double? initialBalance,
    double? monthlyBudget,
    String? currency,
    String? imagePath,
    DateTime? createdAt,
    double? warningThreshold,
    double? criticalThreshold,
    Map<String, double>? categoryBudgets,
    bool? biometricEnabled,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        initialBalance: initialBalance ?? this.initialBalance,
        monthlyBudget: monthlyBudget ?? this.monthlyBudget,
        currency: currency ?? this.currency,
        imagePath: imagePath ?? this.imagePath,
        createdAt: createdAt ?? this.createdAt,
        warningThreshold: warningThreshold ?? this.warningThreshold,
        criticalThreshold: criticalThreshold ?? this.criticalThreshold,
        categoryBudgets: categoryBudgets ?? this.categoryBudgets,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        passwordHash,
        initialBalance,
        monthlyBudget,
        currency,
        imagePath,
        createdAt,
        warningThreshold,
        criticalThreshold,
        categoryBudgets,
        biometricEnabled,
      ];
}