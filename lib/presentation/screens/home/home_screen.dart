import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../core/theme/app_colors.dart';

import 'widgets/balance_card.dart';
import 'widgets/summary_row.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/quickgoals_preview.dart';
import 'widgets/home_header.dart';

class HomeScreen extends StatelessWidget {

  final void Function(int tabIndex) onTabSwitch;

  const HomeScreen({super.key, required this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<TransactionCubit>().loadTransactions();
            context.read<GoalCubit>().loadGoals();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(16),
                HomeHeader(onTabSwitch: onTabSwitch),
                const Gap(24),
                const BalanceCard(),
                const Gap(24),
                const SummaryRow(),
                const Gap(24),
                // ── Weekly chart — "See all" goes to Insights tab ────────
                WeeklyChart(onSeeAll: () => onTabSwitch(3)),
                const Gap(24),
                // ── Goals preview — "See all" goes to Goals tab ──────────
                QuickGoalsPreview(onSeeAll: () => onTabSwitch(2)),
                const Gap(24),
                // ── Recent transactions — "See all" goes to Transactions ─
                RecentTransactions(onSeeAll: () => onTabSwitch(1)),
                const Gap(32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
