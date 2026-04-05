import 'package:flutter/material.dart';

class OnboardingNavigation extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;
  final bool isLast;
  final VoidCallback onNext;

  const OnboardingNavigation({
    super.key,
    required this.count,
    required this.current,
    required this.activeColor,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DotsIndicator(
          count: count,
          current: current,
          activeColor: activeColor,
        ),
        const SizedBox(height: 28),
        _NextButton(
          isLast: isLast,
          color: activeColor,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;

  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : activeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLast;
  final Color color;
  final VoidCallback onTap;

  const _NextButton({
    required this.isLast,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              isLast ? 'Get Started 🚀' : 'Next',
              key: ValueKey(isLast),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
