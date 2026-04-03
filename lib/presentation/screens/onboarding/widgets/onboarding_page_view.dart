import 'package:finance_companion/data/models/onboarding_model.dart';
import 'package:flutter/material.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingPageModel page;
  final Animation<double> illustrationAnim;

  const OnboardingPageContent({
    super.key,
    required this.page,
    required this.illustrationAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          ScaleTransition(
            scale: illustrationAnim,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: page.accent.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Center(child: page.illustration),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 15,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
