


import 'package:finance_companion/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const MenuItem({super.key, 

    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: itemColor, size: 20),
        title: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: itemColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.4),
        ),
        onTap: onTap,
      ),
    );
  }
}