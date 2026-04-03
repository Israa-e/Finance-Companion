import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LoginBackground extends StatelessWidget {
  final Size size;

  const LoginBackground({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Top-right blob ──────────────────────────────
        Positioned(
          top: -90,
          right: -100,
          child: Container(
            width: size.width * 0.72,
            height: size.width * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        // ── Bottom-left blob ─────────────────────────────
        Positioned(
          bottom: -90,
          left: -100,
          child: Container(
            width: size.width * 0.62,
            height: size.width * 0.62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withValues(alpha: 0.07),
            ),
          ),
        ),
      ],
    );
  }
}
