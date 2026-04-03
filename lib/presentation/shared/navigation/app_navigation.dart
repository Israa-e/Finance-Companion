import 'package:finance_companion/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/goal_repository.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../logic/insights/insights_cubit.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/transactions/transactions_screen.dart';
import '../../screens/goals/goals_screen.dart';
import '../../screens/insights/insights_screen.dart';
import '../../../core/theme/app_colors.dart';

class AppNavigation extends StatefulWidget {
  final TransactionRepository transactionRepo;
  final GoalRepository goalRepo;
  final UserModel user;

  const AppNavigation({
    super.key,
    required this.transactionRepo,
    required this.goalRepo,
    required this.user,
  });

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;

  // Tab index constants — single source of truth
  static const int tabHome = 0;
  static const int tabTransactions = 1;
  static const int tabGoals = 2;
  static const int tabInsights = 3;
  static const int tabProfile = 4;

  void _onTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = TransactionCubit(widget.transactionRepo);
            cubit.setUser(widget.user.id!, widget.user.initialBalance);
            cubit.loadTransactions();
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => GoalCubit(widget.goalRepo)
            ..setUser(widget.user.id!)
            ..loadGoals(),
        ),
        BlocProvider(
          create: (_) => InsightsCubit(widget.transactionRepo)..loadInsights(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // HomeScreen gets a callback to switch any tab
            HomeScreen(onTabSwitch: _onTap),
            const TransactionsScreen(),
            const GoalsScreen(),
            const InsightsScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: _buildNavBar(),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _NavItem(
                  icon: Iconsax.home,
                  label: 'Home',
                  index: tabHome,
                  current: _currentIndex,
                  onTap: _onTap,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Iconsax.receipt,
                  label: 'Transactions',
                  index: tabTransactions,
                  current: _currentIndex,
                  onTap: _onTap,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Iconsax.chart,
                  label: 'Goals',
                  index: tabGoals,
                  current: _currentIndex,
                  onTap: _onTap,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Iconsax.graph,
                  label: 'Insights',
                  index: tabInsights,
                  current: _currentIndex,
                  onTap: _onTap,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Iconsax.user,
                  label: 'Profile',
                  index: tabProfile,
                  current: _currentIndex,
                  onTap: _onTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
