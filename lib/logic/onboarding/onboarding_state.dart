import 'package:equatable/equatable.dart';
import '../../data/models/onboarding_model.dart';

enum OnboardingStatus { initial, loading, completed }

class OnboardingState extends Equatable {
  final int currentPage;
  final List<OnboardingPageModel> pages;
  final bool isLastPage;
  final OnboardingStatus status;

  const OnboardingState({
    required this.currentPage,
    required this.pages,
    required this.isLastPage,
    required this.status,
  });

  factory OnboardingState.initial(List<OnboardingPageModel> pages) {
    return OnboardingState(
      currentPage: 0,
      pages: pages,
      isLastPage: pages.length <= 1,
      status: OnboardingStatus.initial,
    );
  }

  OnboardingState copyWith({
    int? currentPage,
    List<OnboardingPageModel>? pages,
    bool? isLastPage,
    OnboardingStatus? status,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      pages: pages ?? this.pages,
      isLastPage: isLastPage ?? this.isLastPage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [currentPage, pages, isLastPage, status];
}

