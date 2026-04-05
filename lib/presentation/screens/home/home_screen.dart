import 'package:finance_companion/logic/streak/streak_cubit.dart';
import 'package:finance_companion/presentation/screens/home/widgets/shimmer_widgets.dart';
import 'package:finance_companion/data/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../logic/transaction/transaction_filter_cubit.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../core/theme/app_colors.dart';

import 'widgets/balance_card.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/quickgoals_preview.dart';
import 'widgets/home_header.dart';
import 'widgets/streak_card.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex) onTabSwitch;

  const HomeScreen({super.key, required this.onTabSwitch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Request notification permission once the Activity is visible.
    // Must be done here (not in main()) so Android can show the dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<TransactionFilterCubit>().load();
            context.read<GoalCubit>().loadGoals();
            context.read<StreakCubit>().loadStreak();
          },
          child: BlocBuilder<TransactionFilterCubit, TransactionFilterState>(
            builder: (context, state) {
              final isLoading = state.isLoading;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16),
                    HomeHeader(onTabSwitch: widget.onTabSwitch),
                    const Gap(16),

                    // Balance card — shimmer while loading
                    isLoading
                        ? const BalanceCardSkeleton()
                        : const BalanceCard(),
                    const Gap(16),

                    // No-Spend Streak — new creative feature
                    const StreakCard(),
                    const Gap(16),

                    // Weekly chart
                    WeeklyChart(onSeeAll: () => widget.onTabSwitch(3)),

                    // Goals preview
                    QuickGoalsPreview(onSeeAll: () => widget.onTabSwitch(2)),
                    // Recent transactions
                    RecentTransactions(onSeeAll: () => widget.onTabSwitch(1)),
                    const Gap(32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
