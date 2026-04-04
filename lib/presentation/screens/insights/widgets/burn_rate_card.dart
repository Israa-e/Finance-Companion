import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../logic/insights/insights_state.dart';

class BurnRateCard extends StatelessWidget {
  final InsightsLoaded state;

  const BurnRateCard({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    if (state.activePeriod != InsightsPeriod.thisMonth) {
      return const SizedBox.shrink(); // Best viewed on current month
    }

    final dailyBurn = state.dailyBurnRate;
    final breachDate = state.predictedBreachDate;
    final isHealthy = breachDate == null || 
        breachDate.isAfter(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHealthy
              ? [AppColors.income.withValues(alpha: 0.1), AppColors.income.withValues(alpha: 0.05)]
              : [AppColors.expense.withValues(alpha: 0.1), AppColors.expense.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isHealthy ? AppColors.income : AppColors.expense).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isHealthy ? AppColors.income : AppColors.expense).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isHealthy ? Iconsax.arrow_up : Iconsax.arrow_down,
                  color: isHealthy ? AppColors.income : AppColors.expense,
                  size: 20,
                ),
              ),
              const Gap(12),
              Text('Predictive Insights', style: AppTextStyles.label),
            ],
          ),
          const Gap(20),
          Text(
            isHealthy 
                ? 'Your spending is sustainable.' 
                : 'Budget breach projected!',
            style: AppTextStyles.h3.copyWith(
              color: isHealthy ? AppColors.income : AppColors.expense,
            ),
          ),
          const Gap(8),
          RichText(
            text: TextSpan(
              style: AppTextStyles.body,
              children: [
                const TextSpan(text: 'Current burn rate: '),
                TextSpan(
                  text: '\$${dailyBurn.toStringAsFixed(2)}/day',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (breachDate != null) ...[
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.calendar_1, size: 16, color: AppColors.textHint),
                  const Gap(8),
                  Text(
                    'Estimate: ${DateFormat('MMM dd, yyyy').format(breachDate)}',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          
          // Senior+ Smart Insight
          const Gap(16),
          _SmartInsight(
            weekdayAvg: state.weekdayAverage,
            weekendAvg: state.weekendAverage,
            isHealthy: isHealthy,
          ),
        ],
      ),
    );
  }
}

class _SmartInsight extends StatelessWidget {
  final double weekdayAvg;
  final double weekendAvg;
  final bool isHealthy;

  const _SmartInsight({
    required this.weekdayAvg,
    required this.weekendAvg,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    final diff = weekendAvg - weekdayAvg;
    final percent = weekdayAvg > 0 ? (diff / weekdayAvg * 100).abs() : 0.0;
    
    if (percent < 10) return const SizedBox.shrink(); // Minimal difference

    final isWkndHigher = diff > 0;
    final color = isHealthy ? AppColors.income : AppColors.expense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.lamp_on, size: 16, color: color),
          const Gap(8),
          Expanded(
            child: Text(
              isWkndHigher 
                ? 'Your weekend spending is ${percent.toStringAsFixed(0)}% higher than weekdays.'
                : 'Great! Your weekend spending is ${percent.toStringAsFixed(0)}% lower than weekdays.',
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
