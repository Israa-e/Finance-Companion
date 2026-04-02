import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import 'widgets/balance_card.dart';
import 'widgets/summary_row.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/weekly_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
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
                _buildHeader(context),
                const Gap(24),
                const BalanceCard(),
                const Gap(16),
                const SummaryRow(),
                const Gap(24),
                const WeeklyChart(),
                const Gap(24),
                const RecentTransactions(),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good ${_greeting()}! 👋', style: AppTextStyles.bodySmall),
            const Gap(2),
            Text('My Finances', style: AppTextStyles.h2),
          ],
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Iconsax.notification, color: AppColors.primary, size: 20),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}