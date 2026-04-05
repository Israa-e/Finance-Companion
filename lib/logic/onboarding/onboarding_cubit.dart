import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_state.dart';
import '../../data/models/onboarding_model.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  static const String prefKey = 'onboarding_complete';

  OnboardingCubit(List<OnboardingPageModel> pages)
      : super(OnboardingState.initial(pages));

  void updatePage(int index) {
    if (index >= 0 && index < state.pages.length) {
      emit(state.copyWith(
        currentPage: index,
        isLastPage: index == state.pages.length - 1,
      ));
    }
  }

  void nextPage() {
    if (!state.isLastPage) {
      updatePage(state.currentPage + 1);
    }
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefKey) ?? false;
  }

  Future<void> finishOnboarding() async {
    emit(state.copyWith(status: OnboardingStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKey, true);
      emit(state.copyWith(status: OnboardingStatus.completed));
    } catch (_) {
      // For now, even if persistence fails, we mark as completed to not block user
      emit(state.copyWith(status: OnboardingStatus.completed));
    }
  }
}
