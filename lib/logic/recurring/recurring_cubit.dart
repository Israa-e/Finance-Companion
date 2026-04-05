import 'package:equatable/equatable.dart';
import 'package:finance_companion/data/models/recurring_transaction_model.dart';
import 'package:finance_companion/data/repositories/recurring_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class RecurringState extends Equatable {
  const RecurringState();

  @override
  List<Object?> get props => [];
}

class RecurringInitial extends RecurringState {}

class RecurringLoading extends RecurringState {}

class RecurringLoaded extends RecurringState {
  final List<RecurringTransactionModel> templates;
  final String? errorMessage;
  final bool isSubmitting;

  const RecurringLoaded({
    required this.templates,
    this.errorMessage,
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [templates, errorMessage, isSubmitting];

  RecurringLoaded copyWith({
    List<RecurringTransactionModel>? templates,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return RecurringLoaded(
      templates: templates ?? this.templates,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class RecurringCubit extends Cubit<RecurringState> {
  final RecurringRepository _repository;
  int? _userId;

  RecurringCubit(this._repository) : super(RecurringInitial());

  void setUser(int userId) {
    _userId = userId;
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    if (_userId == null) return;
    emit(RecurringLoading());
    try {
      final templates = await _repository.getAll(_userId!);
      emit(RecurringLoaded(templates: templates));
    } catch (e) {
      emit(RecurringInitial()); // Or error state
    }
  }

  Future<void> addTemplate({
    required String title,
    required double amount,
    required String type,
    required String category,
    String? note,
    required RecurringFrequency frequency,
    required DateTime nextDate,
  }) async {
    if (_userId == null) return;
    final currentState = state;
    if (currentState is RecurringLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      try {
        final newTemplate = RecurringTransactionModel(
          id: RecurringRepository.generateId(),
          userId: _userId!,
          title: title,
          amount: amount,
          type: type,
          category: category,
          note: note,
          frequency: frequency,
          nextDate: nextDate,
          createdAt: DateTime.now(),
        );
        await _repository.insert(newTemplate);
        await loadTemplates();
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Failed to add recurring bill: $e',
          isSubmitting: false,
        ));
      }
    }
  }

  Future<void> toggleActive(RecurringTransactionModel template) async {
    final currentState = state;
    if (currentState is RecurringLoaded) {
      try {
        final updated = template.copyWith(isActive: !template.isActive);
        await _repository.update(updated);
        await loadTemplates();
      } catch (_) {}
    }
  }

  Future<void> deleteTemplate(String id) async {
    final currentState = state;
    if (currentState is RecurringLoaded) {
      try {
        await _repository.delete(id);
        await loadTemplates();
      } catch (_) {}
    }
  }
}
