import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/auth/auth_state.dart';
import 'package:finance_companion/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../logic/insights/insights_state.dart';

/// Surfaces weekday vs. weekend spending variance — always visible regardless
/// of the selected [InsightsPeriod], as long as there is enough data.
class SpendingPatternCard extends StatelessWidget {
  final InsightsLoaded state;

  const SpendingPatternCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final weekdayAvg = state.weekdayAverage;
    final weekendAvg = state.weekendAverage;

    // Only render when there is meaningful data in at least one window
    if (weekdayAvg == 0 && weekendAvg == 0) return const SizedBox.shrink();

    final diff = weekendAvg - weekdayAvg;
    final percent = weekdayAvg > 0 ? (diff / weekdayAvg * 100).abs() : 0.0;
    final isWeekendHigher = diff > 0;
    final accentColor = isWeekendHigher ? AppColors.expense : AppColors.income;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.calendar_tick,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const Gap(12),
              Text(
                'Spending Patterns',
                style: AppTextStyles.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Gap(16),

          // ── Summary sentence ──────────────────────────────────────
          if (percent >= 5)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.lamp_on, size: 14, color: accentColor),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      isWeekendHigher
                          ? 'You spend ${percent.toStringAsFixed(0)}% more on weekends than weekdays.'
                          : 'Great! You spend ${percent.toStringAsFixed(0)}% less on weekends than weekdays.',
                      style: AppTextStyles.caption.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Gap(16),

          // ── Bar comparison ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _PatternBar(
                  label: 'Weekdays',
                  avg: weekdayAvg,
                  maxAvg: weekdayAvg > weekendAvg ? weekdayAvg : weekendAvg,
                  color: AppColors.primary,
                  icon: Iconsax.briefcase,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _PatternBar(
                  label: 'Weekends',
                  avg: weekendAvg,
                  maxAvg: weekdayAvg > weekendAvg ? weekdayAvg : weekendAvg,
                  color: accentColor,
                  icon: Iconsax.cup,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatternBar extends StatelessWidget {
  final String label;
  final double avg;
  final double maxAvg;
  final Color color;
  final IconData icon;

  const _PatternBar({
    required this.label,
    required this.avg,
    required this.maxAvg,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxAvg > 0 ? (avg / maxAvg).clamp(0.0, 1.0) : 0.0;
    
    // Multi-currency support fix: use dynamic formatter
    final formatter = context.select<AuthCubit, CurrencyFormatter>((c) =>
        c.state is AuthAuthenticated
            ? (c.state as AuthAuthenticated).formatter
            : const CurrencyFormatter());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const Gap(6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const Gap(8),
        // Animated fill bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const Gap(6),
        Text(
          '${formatter.format(avg)} / txn',
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
