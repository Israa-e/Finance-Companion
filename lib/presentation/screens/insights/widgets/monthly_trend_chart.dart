// monthly_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../logic/insights/insights_state.dart';

class MonthlyTrendChart extends StatelessWidget {
  final InsightsLoaded state;
  const MonthlyTrendChart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final entries = state.monthlyTrend.entries.toList();
    final maxVal = entries.isEmpty
        ? 1.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // Find the bar with the highest value to highlight it
    int maxIndex = 0;
    for (int i = 1; i < entries.length; i++) {
      if (entries[i].value > entries[maxIndex].value) maxIndex = i;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Trend',
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Expenses over the last 6 months',
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Legend ──────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Gap(5),
                  Text(
                    'Expenses',
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.3,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 3,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            entries[idx].key,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color: idx == maxIndex
                                  ? AppColors.expense
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                              fontWeight: idx == maxIndex
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(entries.length, (i) {
                  final isMax = i == maxIndex;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entries[i].value == 0 ? 0.5 : entries[i].value,
                        gradient: LinearGradient(
                          colors: isMax
                              ? [
                                  AppColors.expense.withValues(alpha: 0.7),
                                  AppColors.expense,
                                ]
                              : [
                                  AppColors.primary.withValues(alpha: 0.4),
                                  AppColors.primary.withValues(alpha: 0.7),
                                ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal * 1.3,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.04),
                        ),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Theme.of(context).colorScheme.surface,
                    tooltipRoundedRadius: 10,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      CurrencyFormatter.formatCompact(rod.toY),
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
