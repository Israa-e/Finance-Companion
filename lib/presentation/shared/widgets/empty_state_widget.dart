import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 220 || constraints.maxWidth < 260;
        final padding = compact ? 16.0 : 32.0;
        final iconSize = compact ? 52.0 : 80.0;
        final titleStyle = AppTextStyles.h3.copyWith(
          fontSize: compact ? 18 : 22,
          height: 1.3,
        );
        final subtitleStyle = AppTextStyles.bodySmall.copyWith(
          fontSize: compact ? 12 : 14,
          height: 1.5,
        );
        return Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon ?? Iconsax.document,
                    size: compact ? 28 : 36,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: compact ? 16 : 20),
                Text(title, style: titleStyle, textAlign: TextAlign.center),
                SizedBox(height: compact ? 6 : 8),
                Text(
                  subtitle,
                  style: subtitleStyle,
                  textAlign: TextAlign.center,
                ),
                if (action != null) ...[
                  SizedBox(height: compact ? 18 : 24),
                  action!,
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
