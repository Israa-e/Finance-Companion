
// ─── Stat Card ────────────────────────────────────────────────────────────────

import 'package:finance_companion/core/theme/app_text_styles.dart';
import 'package:finance_companion/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const StatCard({super.key, 

    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: AppTextStyles.amountSmall.copyWith(color: color),
            ),
            const Gap(4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}