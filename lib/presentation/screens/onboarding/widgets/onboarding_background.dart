import 'package:flutter/material.dart';

class OnboardingBackground extends StatelessWidget {
  final Size size;
  final int currentPage;
  final Color accentColor;

  const OnboardingBackground({
    super.key,
    required this.size,
    required this.currentPage,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          top: -size.height * 0.12,
          right: currentPage.isEven ? -60.0 : size.width * 0.1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            width: size.width * 0.75,
            height: size.width * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.09),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
          bottom: -size.height * 0.08,
          left: currentPage.isEven ? -40.0 : size.width * 0.15,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            width: size.width * 0.5,
            height: size.width * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.06),
            ),
          ),
        ),
      ],
    );
  }
}
