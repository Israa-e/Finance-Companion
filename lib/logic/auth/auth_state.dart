import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String? editName;
  final String? editImagePath;
  final bool isUpdating;
  final bool updateSuccess;
  final String? errorMessage;

  const AuthAuthenticated({
    required this.user,
    this.editName,
    this.editImagePath,
    this.isUpdating = false,
    this.updateSuccess = false,
    this.errorMessage,
  });

  AuthAuthenticated copyWith({
    UserModel? user,
    String? editName,
    String? editImagePath,
    bool? isUpdating,
    bool? updateSuccess,
    String? errorMessage,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      editName: editName ?? this.editName,
      editImagePath: editImagePath ?? this.editImagePath,
      isUpdating: isUpdating ?? this.isUpdating,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        user,
        editName,
        editImagePath,
        isUpdating,
        updateSuccess,
        errorMessage,
      ];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}