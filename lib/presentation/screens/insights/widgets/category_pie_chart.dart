import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../logic/insights/insights_state.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import 'category_drilldown_sheet.dart';

class CategoryPieChart extends StatefulWidget {
  final InsightsLoaded state;

  const CategoryPieChart({super.key, required this.state});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.state.expensesByCategory.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);
    final colorCount = AppColors.categoryColors.length;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spending by Category', style: AppTextStyles.h3),
              const Icon(Icons.touch_app, size: 16, color: Colors.grey),
            ],
          ),
          const Gap(20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;

                      // Trigger drill-down on tap
                      if (event is FlTapUpEvent && touchedIndex != -1) {
                        _showDrilldown(context, entries[touchedIndex].key);
                      }
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: List.generate(entries.length, (i) {
                  final isTouched = i == touchedIndex;
                  final pct = entries[i].value / total * 100;
                  final color = AppColors.categoryColors[i % colorCount];
                  final radius = isTouched ? 70.0 : 60.0;
                  final fontSize = isTouched ? 14.0 : 11.0;

                  return PieChartSectionData(
                    color: color,
                    value: entries[i].value,
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const Gap(16),
          ...List.generate(
            entries.length,
            (i) {
              final isTouched = i == touchedIndex;
              return GestureDetector(
                onTap: () => _showDrilldown(context, entries[i].key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isTouched
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.categoryColors[i % colorCount],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final authState = context.watch<AuthCubit>().state;
                          final formatter = authState is AuthAuthenticated
                              ? authState.formatter
                              : const CurrencyFormatter();
                          return Text(
                            formatter.format(entries[i].value),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDrilldown(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryDrilldownSheet(
        category: category,
        transactions: widget.state.transactions,
      ),
    );
  }
}
