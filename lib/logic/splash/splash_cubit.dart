import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState.initial());

  Future<void> startSequence() async {
    // Initial delay
    await Future.delayed(const Duration(milliseconds: 100));
    emit(state.copyWith(status: SplashStatus.animating));

    // Wait for internal animations + show duration
    // (We match the previous timing from splash_screen.dart)
    // 200 (logo) + 600 (text) + 1800 (hold) + 400 (exit) = 3000ms approx
    await Future.delayed(const Duration(milliseconds: 3100));
    
    emit(state.copyWith(status: SplashStatus.completed));
  }
}
