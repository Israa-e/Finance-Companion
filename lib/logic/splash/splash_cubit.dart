import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  Timer? _timer;

  SplashCubit() : super(SplashState.initial());

  Future<void> startSequence() async {
    // Initial delay
    _timer = Timer(const Duration(milliseconds: 100), () {
      if (!isClosed) {
        emit(state.copyWith(status: SplashStatus.animating));
        
        // Wait for internal animations + show duration
        _timer = Timer(const Duration(milliseconds: 3100), () {
          if (!isClosed) {
            emit(state.copyWith(status: SplashStatus.completed));
          }
        });
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
