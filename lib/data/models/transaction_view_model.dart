import 'dart:convert';
import 'package:finance_companion/logic/transaction/transaction_state.dart';

class TransactionView {
  final String id;
  final int userId;
  final String name;
  final TransactionFilter filter;
  final String searchQuery;
  final List<String>? selectedCategories;
  final DateTime createdAt;

  TransactionView({
    required this.id,
    required this.userId,
    required this.name,
    this.filter = TransactionFilter.all,
    this.searchQuery = '',
    this.selectedCategories,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'filter': filter.name,
      'searchQuery': searchQuery,
      'selectedCategories': selectedCategories != null ? jsonEncode(selectedCategories) : null,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionView.fromMap(Map<String, dynamic> map) {
    return TransactionView(
      id: map['id'] as String,
      userId: map['userId'] as int,
      name: map['name'] as String,
      filter: TransactionFilter.values.firstWhere(
        (e) => e.name == map['filter'],
        orElse: () => TransactionFilter.all,
      ),
      searchQuery: map['searchQuery'] as String? ?? '',
      selectedCategories: map['selectedCategories'] != null
          ? List<String>.from(jsonDecode(map['selectedCategories'] as String))
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  TransactionView copyWith({
    String? name,
    TransactionFilter? filter,
    String? searchQuery,
    List<String>? selectedCategories,
  }) {
    return TransactionView(
      id: id,
      userId: userId,
      name: name ?? this.name,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      createdAt: createdAt,
    );
  }
}
