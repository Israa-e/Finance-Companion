import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_state.dart';
import '../../data/models/onboarding_model.dart';
import '../../presentation/screens/onboarding/widgets/onboarding_illustrations.dart';
import 'package:flutter/material.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  static const String prefKey = 'onboarding_complete';

  OnboardingCubit() : super(OnboardingState.initial([
    const OnboardingPageModel(
      title: 'Track Every\nPenny',
      subtitle: 'Log income and expenses in seconds. Know exactly where your money goes every single day.',
      accent: Color(0xFF6C63FF),
      illustration: IllustrationWallet(),
    ),
    const OnboardingPageModel(
      title: 'Smart\nInsights',
      subtitle: 'Beautiful charts reveal your spending habits. Spot trends before they become problems.',
      accent: Color(0xFF2DCE89),
      illustration: IllustrationChart(),
    ),
    const OnboardingPageModel(
      title: 'Reach Your\nGoals',
      subtitle: 'Set savings goals, track progress, and celebrate every milestone on your path to financial freedom.',
      accent: Color(0xFFFFBF00),
      illustration: IllustrationGoal(),
    ),
  ]));

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

