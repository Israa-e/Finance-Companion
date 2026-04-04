import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;
  final bool isField;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.icon,
    this.isOutlined = false,
    this.isField = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? AppColors.primary;

    // Matching CustomTextField fill color logic
    final fieldFillColor = theme.inputDecorationTheme.fillColor ??
        (theme.brightness == Brightness.light
            ? Colors.grey[100]
            : theme.colorScheme.surface);

    final contentColor = isField
        ? (textColor ?? theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface)
        : isOutlined
            ? (textColor ?? theme.colorScheme.onSurface)
            : (textColor ?? Colors.white);

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: contentColor,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisAlignment: (isOutlined || isField) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: isField ? theme.hintColor : contentColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: 14, // Matching CustomTextField font size
                      fontWeight: FontWeight.w500, // Matching CustomTextField font weight
                    ),
                  ),
                ],
              ),
              if (isOutlined || isField)
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: (isField ? theme.hintColor : contentColor).withValues(alpha: 0.5),
                ),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 56, // Slightly taller to match CustomTextField's standard height
      child: (isOutlined || isField)
          ? OutlinedButton(
              onPressed: isLoading ? null : onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: isField ? fieldFillColor : Colors.transparent,
                side: isField 
                    ? BorderSide.none 
                    : BorderSide(color: theme.dividerColor, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
              ),
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: buttonChild,
            ),
    );
  }
}