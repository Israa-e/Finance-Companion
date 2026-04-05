import 'package:equatable/equatable.dart';
import 'package:finance_companion/data/models/category_model.dart';
import 'package:finance_companion/data/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final String? errorMessage;
  final bool isSubmitting;

  const CategoryLoaded({
    required this.categories,
    this.errorMessage,
    this.isSubmitting = false,
  });

  List<CategoryModel> get incomeCategories =>
      categories.where((c) => c.isIncome).toList();
  List<CategoryModel> get expenseCategories =>
      categories.where((c) => c.isExpense).toList();

  @override
  List<Object?> get props => [categories, errorMessage, isSubmitting];

  CategoryLoaded copyWith({
    List<CategoryModel>? categories,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;
  int? _userId;

  CategoryCubit(this._repository) : super(CategoryInitial());

  void setUser(int userId) {
    _userId = userId;
    loadCategories();
  }

  Future<void> loadCategories() async {
    if (_userId == null) return;
    emit(CategoryLoading());
    try {
      final categories = await _repository.getAll(_userId!);
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories: $e'));
    }
  }

  Future<void> addCategory({
    required String name,
    required int iconCode,
    required int colorValue,
    required String type,
  }) async {
    if (_userId == null) return;
    final currentState = state;
    if (currentState is CategoryLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      try {
        final newCategory = CategoryModel(
          id: CategoryRepository.generateId(),
          name: name,
          iconCode: iconCode,
          colorValue: colorValue,
          type: type,
          userId: _userId,
          createdAt: DateTime.now(),
        );
        await _repository.insert(newCategory);
        await loadCategories();
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Failed to add category: $e',
          isSubmitting: false,
        ));
      }
    }
  }

  Future<void> deleteCategory(String id) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      try {
        await _repository.delete(id);
        await loadCategories();
      } catch (e) {
        emit(currentState.copyWith(errorMessage: 'Failed to delete: $e'));
      }
    }
  }
}
