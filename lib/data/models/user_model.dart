import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final double initialBalance;
  final String? imagePath;
  final DateTime createdAt;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.initialBalance,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'initialBalance': initialBalance,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        passwordHash: map['passwordHash'],
        initialBalance: (map['initialBalance'] as num).toDouble(),
        imagePath: map['imagePath'],
        createdAt: DateTime.parse(map['createdAt']),
      );

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    double? initialBalance,
    String? imagePath,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        initialBalance: initialBalance ?? this.initialBalance,
        imagePath: imagePath ?? this.imagePath,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [id, name, email, passwordHash, initialBalance, imagePath];
}