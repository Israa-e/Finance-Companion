import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import '../../../../logic/insights/insights_cubit.dart';
import '../../../../logic/insights/insights_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

class WeeklyChart extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const WeeklyChart({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InsightsCubit, InsightsState>(
      builder: (context, state) {
        if (state is! InsightsLoaded) return const SizedBox.shrink();

        final data = state.weeklyExpenses;
        final keys = data.keys.toList(); // format: "day/month"
        final values = data.values.toList();
        final maxVal =
            values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);

        // Build short labels like "Mon 4" from the "day/month" keys
        final now = DateTime.now();
        final shortLabels = List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          // weekday: Mon=1 … Sun=7
          return names[day.weekday - 1];
        });

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weekly Spending', style: AppTextStyles.h3),
                  if (onSeeAll != null)
                    TextButton(
                      onPressed: onSeeAll,
                      child: Text(
                        'See all',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(4),
              // FIX: show the date range so context is clear
              Text(
                _dateRange(now),
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.45),
                ),
              ),
              const Gap(16),
              SizedBox(
                height: 150,
                child: BarChart(
                  BarChartData(
                    maxY: maxVal == 0 ? 10 : maxVal * 1.25,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxVal == 0 ? 5 : maxVal / 3,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.06),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor:
                            Theme.of(context).colorScheme.surface,
                        tooltipRoundedRadius: 10,
                        getTooltipItem: (group, _, rod, __) =>
                            BarTooltipItem(
                          CurrencyFormatter.formatCompact(rod.toY),
                          TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, _) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= shortLabels.length) {
                              return const SizedBox();
                            }
                            final isToday = idx == 6;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                shortLabels[idx],
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isToday
                                      ? AppColors.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(values.length, (i) {
                      final isToday = i == values.length - 1;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: values[i] == 0 ? 0.2 : values[i],
                            gradient: LinearGradient(
                              colors: isToday
                                  ? [
                                      AppColors.primary.withValues(
                                          alpha: 0.7),
                                      AppColors.primary,
                                    ]
                                  : [
                                      AppColors.primary.withValues(
                                          alpha: 0.3),
                                      AppColors.primary.withValues(
                                          alpha: 0.6),
                                    ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 20,
                            borderRadius: BorderRadius.circular(6),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxVal == 0 ? 10 : maxVal * 1.25,
                              color: AppColors.primary.withValues(
                                  alpha: 0.05),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _dateRange(DateTime now) {
    final start = now.subtract(const Duration(days: 6));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[start.month - 1]} ${start.day} – ${months[now.month - 1]} ${now.day}';
  }
}