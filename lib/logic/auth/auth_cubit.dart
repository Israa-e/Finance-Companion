import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _repo.getLoggedInUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
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
      emit(AuthAuthenticated(user: user));
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
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthUnauthenticated());
  }

  // ── Profile editing helpers ───────────────────────────────────────────────

  bool _isPickingImage = false;

  void updateEditName(String name) {
    final current = state;
    if (current is AuthAuthenticated) {
      emit(current.copyWith(editName: name));
    }
  }

  Future<void> pickEditImage() async {
    final path = await pickImage();
    final current = state;
    if (current is AuthAuthenticated && path != null) {
      emit(current.copyWith(editImagePath: path));
    }
  }

  Future<void> saveProfile({
    required String name,
    String? imagePath,
    required double initialBalance,
    double monthlyBudget = 0.0,
    String currency = 'USD',
    double? warningThreshold,
    double? criticalThreshold,
    Map<String, double>? categoryBudgets,
    bool? biometricEnabled,
  }) async {
    final current = state;
    if (current is! AuthAuthenticated) return;

    emit(current.copyWith(isUpdating: true, errorMessage: null));
    try {
      final updatedUser = current.user.copyWith(
        name: name.trim(),
        imagePath: imagePath ?? current.user.imagePath,
        initialBalance: initialBalance,
        monthlyBudget: monthlyBudget,
        currency: currency,
        warningThreshold: warningThreshold ?? current.user.warningThreshold,
        criticalThreshold: criticalThreshold ?? current.user.criticalThreshold,
        categoryBudgets: categoryBudgets ?? current.user.categoryBudgets,
        biometricEnabled: biometricEnabled ?? current.user.biometricEnabled,
      );
      await _repo.updateProfile(updatedUser);
      emit(current.copyWith(
        user: updatedUser,
        isUpdating: false,
        updateSuccess: true,
      ));
    } catch (e) {
      emit(current.copyWith(isUpdating: false, errorMessage: e.toString()));
    }
  }

  Future<String?> pickImage() async {
    if (_isPickingImage) return null;
    _isPickingImage = true;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      return picked?.path;
    } finally {
      _isPickingImage = false;
    }
  }
}
