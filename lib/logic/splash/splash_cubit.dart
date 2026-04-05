import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../../data/repositories/auth_repository.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthRepository _authRepo;
  final LocalAuthentication _localAuth = LocalAuthentication();
  Timer? _timer;

  SplashCubit(this._authRepo) : super(SplashState.initial());

  Future<void> startSequence() async {
    // 1. Show opening animation
    emit(state.copyWith(status: SplashStatus.animating));

    // 2. Minimum animation duration (2 seconds)
    await Future.delayed(const Duration(milliseconds: 2000));

    // 3. Check if user is logged in AND has biometric enabled
    final user = await _authRepo.getLoggedInUser();
    if (user != null && user.biometricEnabled) {
      emit(state.copyWith(status: SplashStatus.authenticating));
      final authenticated = await _authenticate();
      if (authenticated) {
        emit(state.copyWith(status: SplashStatus.completed));
      } else {
        emit(state.copyWith(
          status: SplashStatus.error,
          errorMessage: 'Authentication failed. Please restart the app.',
        ));
      }
    } else {
      // No biometric needed — proceed
      emit(state.copyWith(status: SplashStatus.completed));
    }
  }

  Future<bool> _authenticate() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) {
        return true; // Fallback if hardware missing
      }

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your finance companion',
        );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
