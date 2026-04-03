import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../logic/insights/insights_state.dart';

class CategoryPieChart extends StatelessWidget {
  final InsightsLoaded state;

  const CategoryPieChart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final entries = state.expensesByCategory.entries.toList();
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
          Text('Spending by Category', style: AppTextStyles.h3),
          const Gap(20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: List.generate(entries.length, (i) {
                  final pct = entries[i].value / total * 100;
                  final color = AppColors.categoryColors[i % colorCount];
                  return PieChartSectionData(
                    color: color,
                    value: entries[i].value,
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 11,
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
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(entries[i].value),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
