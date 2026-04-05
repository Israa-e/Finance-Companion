import 'package:finance_companion/data/models/onboarding_model.dart';
import 'package:flutter/material.dart';
import 'widgets/onboarding_background.dart';
import 'widgets/onboarding_navigation.dart';
import 'widgets/onboarding_page_view.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/onboarding/onboarding_cubit.dart';
import '../../../logic/onboarding/onboarding_state.dart';

import 'package:finance_companion/l10n/app_localizations.dart';

import 'widgets/onboarding_illustrations.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();

  // Per-page animation controllers
  late final List<AnimationController> _illustrationCtrls;
  late final List<Animation<double>> _illustrationAnims;

  @override
  void initState() {
    super.initState();

    const pagesCount = 3;

    _illustrationCtrls = List.generate(
      pagesCount,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      ),
    );

    _illustrationAnims = _illustrationCtrls.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.elasticOut);
    }).toList();

    _illustrationCtrls[0].forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _illustrationCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index, OnboardingCubit cubit) {
    cubit.updatePage(index);
    _illustrationCtrls[index].forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      OnboardingPageModel(
        title: l10n.onboarding1Title,
        subtitle: l10n.onboarding1Subtitle,
        accent: const Color(0xFF6C63FF),
        illustration: const IllustrationWallet(),
      ),
      OnboardingPageModel(
        title: l10n.onboarding2Title,
        subtitle: l10n.onboarding2Subtitle,
        accent: const Color(0xFF2DCE89),
        illustration: const IllustrationChart(),
      ),
      OnboardingPageModel(
        title: l10n.onboarding3Title,
        subtitle: l10n.onboarding3Subtitle,
        accent: const Color(0xFFFFBF00),
        illustration: const IllustrationGoal(),
      ),
    ];

    return BlocProvider(
      create: (context) => OnboardingCubit(pages),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.status == OnboardingStatus.completed) {
            widget.onDone();
          }
        },
        builder: (context, state) {
          final cubit = context.read<OnboardingCubit>();
          final page = state.pages[state.currentPage];
          final size = MediaQuery.of(context).size;

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Stack(
              children: [
                OnboardingBackground(
                  size: size,
                  currentPage: state.currentPage,
                  accentColor: page.accent,
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, top: 12),
                          child: TextButton(
                            onPressed: cubit.finishOnboarding,
                            child: Text(
                              AppLocalizations.of(context)!.skip,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    )
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.75),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageCtrl,
                          onPageChanged: (i) => _onPageChanged(i, cubit),
                          itemCount: state.pages.length,
                          itemBuilder: (_, i) {
                            return OnboardingPageContent(
                              page: state.pages[i],
                              illustrationAnim: _illustrationAnims[i],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                        child: OnboardingNavigation(
                          count: state.pages.length,
                          current: state.currentPage,
                          activeColor: page.accent,
                          isLast: state.isLastPage,
                          onNext: () {
                            if (state.isLastPage) {
                              cubit.finishOnboarding();
                            } else {
                              _pageCtrl.nextPage(
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.status == OnboardingStatus.loading)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
