import 'dart:io';
import 'package:finance_companion/presentation/screens/home/widgets/quickgoals_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import 'widgets/balance_card.dart';
import 'widgets/summary_row.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/weekly_chart.dart';

class HomeScreen extends StatelessWidget {
  /// Callback to switch the root [AppNavigation] tab.
  /// Index constants: 0 Home · 1 Transactions · 2 Goals · 3 Insights · 4 Profile
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
                _buildHeader(context),
                const Gap(24),
                const BalanceCard(),
                const Gap(20),
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

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final imagePath = user?.imagePath;
        final name = user?.name.split(' ').first ?? '';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()} 👋',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Gap(2),
                Text(
                  name.isNotEmpty ? name : 'My Finances',
                  style: AppTextStyles.h2,
                ),
              ],
            ),
            Row(
              children: [
                // Notification bell — taps to Insights for now
                GestureDetector(
                  onTap: () => onTabSwitch(3),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Iconsax.notification,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.expense,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(10),
                // Avatar — taps to Profile tab
                GestureDetector(
                  onTap: () => onTabSwitch(4),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                      image: imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(imagePath)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imagePath == null
                        ? const Icon(
                            Iconsax.user,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
