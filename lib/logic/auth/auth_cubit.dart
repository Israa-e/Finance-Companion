import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  // Check session on app start
  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _repo.getLoggedInUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required double initialBalance,
    String? imagePath,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _repo.register(
        name: name,
        email: email,
        password: password,
        initialBalance: initialBalance,
        imagePath: imagePath,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _repo.login(email: email, password: password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> updateProfile({
    required String name,
    String? imagePath,
  }) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    try {
      final updated = current.user.copyWith(
        name: name,
        imagePath: imagePath ?? current.user.imagePath,
      );
      await _repo.updateProfile(updated);
      emit(AuthAuthenticated(updated));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<String?> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    return picked?.path;
  }
}