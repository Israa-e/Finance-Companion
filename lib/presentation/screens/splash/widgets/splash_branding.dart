import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SplashBranding extends StatelessWidget {
  final Animation<double> logoScale;
  final Animation<double> logoFade;
  final Animation<double> ringExpand;
  final Animation<double> textFade;
  final Animation<Offset> textSlide;

  const SplashBranding({
    super.key,
    required this.logoScale,
    required this.logoFade,
    required this.ringExpand,
    required this.textFade,
    required this.textSlide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo with expanding ring
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Transform.scale(
                scale: 0.6 + 0.4 * ringExpand.value,
                child: Opacity(
                  opacity: ringExpand.value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // Inner ring
              Transform.scale(
                scale: 0.7 + 0.3 * ringExpand.value,
                child: Opacity(
                  opacity: ringExpand.value * 0.5,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),
              ),
              // Logo icon
              ScaleTransition(
                scale: logoScale,
                child: FadeTransition(
                  opacity: logoFade,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // App name + tagline
        FadeTransition(
          opacity: textFade,
          child: SlideTransition(
            position: textSlide,
            child: Column(
              children: [
                const Text(
                  'Finance Companion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Smart money, better life',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
