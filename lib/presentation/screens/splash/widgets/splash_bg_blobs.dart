import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SplashBgBlobs extends StatelessWidget {
  final Size size;
  final Animation<double> bgAnimation;

  const SplashBgBlobs({
    super.key,
    required this.size,
    required this.bgAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBlob(
          size,
          top: -size.height * 0.08,
          left: -size.width * 0.15,
          diameter: size.width * 0.8,
          color: AppColors.primaryLight,
          opacity: 0.18 * bgAnimation.value,
        ),
        _buildBlob(
          size,
          bottom: -size.height * 0.18,
          right: -size.width * 0.2,
          diameter: size.width * 0.7,
          color: AppColors.primary,
          opacity: 0.23 * bgAnimation.value,
        ),
      ],
    );
  }

  Widget _buildBlob(
    Size size, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double diameter,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
