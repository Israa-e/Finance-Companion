import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';

class TransactionFormState extends Equatable {
  final TransactionType type;
  final String category;
  final double amount;
  final DateTime date;
  final String title;
  final String note;
  
  final bool isSubmitting;
  final bool submitSuccess;
  final String? errorMessage;

  const TransactionFormState({
    this.type = TransactionType.expense,
    this.category = 'Food & Drinks',
    this.amount = 0.0,
    required this.date,
    this.title = '',
    this.note = '',
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.errorMessage,
  });

  TransactionFormState copyWith({
    TransactionType? type,
    String? category,
    double? amount,
    DateTime? date,
    String? title,
    String? note,
    bool? isSubmitting,
    bool? submitSuccess,
    String? errorMessage,
  }) {
    return TransactionFormState(
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      title: title ?? this.title,
      note: note ?? this.note,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? false,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    type, category, amount, date, title, note,
    isSubmitting, submitSuccess, errorMessage
  ];
}

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit() : super(TransactionFormState(date: DateTime.now()));

  void reset() => emit(TransactionFormState(date: DateTime.now()));

  void initForEdit(TransactionModel tx) {
    emit(TransactionFormState(
      type: tx.type,
      category: tx.category,
      amount: tx.amount,
      date: tx.date,
      title: tx.title,
      note: tx.note ?? '',
    ));
  }

  void updateType(TransactionType type) {
    final category = type == TransactionType.expense ? 'Food & Drinks' : 'Salary';
    emit(state.copyWith(type: type, category: category));
  }

  void updateCategory(String category) => emit(state.copyWith(category: category));
  void updateAmount(double amount) => emit(state.copyWith(amount: amount));
  void updateDate(DateTime date) => emit(state.copyWith(date: date));
  void updateTitle(String title) => emit(state.copyWith(title: title));
  void updateNote(String note) => emit(state.copyWith(note: note));

  void setSubmitting(bool isSubmitting) => emit(state.copyWith(isSubmitting: isSubmitting));
  void setError(String? message) => emit(state.copyWith(errorMessage: message, isSubmitting: false));
  void setSuccess() => emit(state.copyWith(submitSuccess: true, isSubmitting: false));
}
