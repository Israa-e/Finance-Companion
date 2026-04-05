import 'package:finance_companion/data/repositories/notification_repository.dart';
import 'package:finance_companion/logic/streak/streak_cubit.dart';
import 'package:finance_companion/logic/notification/notification_cubit.dart';
import 'package:finance_companion/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:finance_companion/injection_container.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/goal_repository.dart';
import '../../../logic/transaction/transaction_action_cubit.dart';
import '../../../logic/transaction/transaction_filter_cubit.dart';
import '../../../logic/transaction/transaction_form_cubit.dart';
import '../../../logic/goal/goal_cubit.dart';
import '../../../logic/insights/insights_cubit.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/transactions/transactions_screen.dart';
import '../../screens/goals/goals_screen.dart';
import '../../screens/insights/insights_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/alert_service.dart';
import 'package:finance_companion/logic/navigation/tab_navigation_cubit.dart';
import 'package:finance_companion/logic/category/category_cubit.dart';
import 'package:finance_companion/logic/recurring/recurring_cubit.dart';
import 'package:finance_companion/data/repositories/category_repository.dart';
import 'package:finance_companion/data/repositories/recurring_repository.dart';
import 'package:finance_companion/data/services/recurring_processor_service.dart';
import 'package:finance_companion/l10n/app_localizations.dart';


class AppNavigation extends StatefulWidget {
  final UserModel user;

  const AppNavigation({
    super.key,
    required this.user,
  });

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  static const int tabHome = 0;
  static const int tabTransactions = 1;
  static const int tabGoals = 2;
  static const int tabInsights = 3;
  static const int tabProfile = 4;

  late final TransactionActionCubit _txActionCubit;
  late final TransactionFilterCubit _txFilterCubit;
  late final TransactionFormCubit _txFormCubit;
  late final GoalCubit _goalCubit;
  late final InsightsCubit _insightsCubit;
  late final StreakCubit _streakCubit;
  late final NotificationCubit _notifCubit;
  late final CategoryCubit _categoryCubit;
  late final RecurringCubit _recurringCubit;
  late final AlertService _alertService;

  @override
  void initState() {
    super.initState();

    _insightsCubit = InsightsCubit(
      sl<TransactionRepository>(),
      userMonthlyBudget: widget.user.monthlyBudget,
    )..loadInsights();
    _streakCubit = StreakCubit(sl<TransactionRepository>())..loadStreak();

    _alertService = sl<AlertService>();
    _notifCubit = NotificationCubit(sl<NotificationRepository>())..load();

    _categoryCubit = CategoryCubit(sl<CategoryRepository>())..setUser(widget.user.id!);
    _recurringCubit = RecurringCubit(sl<RecurringRepository>())..setUser(widget.user.id!);

    _txFilterCubit = sl<TransactionFilterCubit>()..setUser(widget.user.id!, widget.user.initialBalance)..load();
    _txActionCubit = sl<TransactionActionCubit>()..setAlertParams(
      monthlyBudget: widget.user.monthlyBudget,
      warningThreshold: widget.user.warningThreshold,
      criticalThreshold: widget.user.criticalThreshold,
    );
    _txFormCubit = sl<TransactionFormCubit>();

    _goalCubit = GoalCubit(sl<GoalRepository>(), sl<TransactionRepository>(), _alertService)
      ..setUser(widget.user.id!)
      ..loadGoals();

    _runStartupChecks();
  }

  Future<void> _runStartupChecks() async {
    try {
      final processor = sl<RecurringProcessorService>();
      final processed = await processor.processDue(widget.user.id!);
      if (processed > 0) {
        _txFilterCubit.load();
      }

      final transactions = await sl<TransactionRepository>().getAll();
      await _alertService.checkBudgetAlerts(
        transactions: transactions,
        monthlyBudget: widget.user.monthlyBudget,
        warningThreshold: widget.user.warningThreshold,
        criticalThreshold: widget.user.criticalThreshold,
      );
      final goals = await sl<GoalRepository>().getAll(widget.user.id!);
      await _alertService.checkGoalAlerts(goals);

      final streakState = _streakCubit.state;
      if (streakState is StreakLoaded) {
        await _alertService.checkStreakAlerts(streakState.streak.currentStreak);
      }

      _notifCubit.load();
    } catch (_) {}
  }

  @override
  void dispose() {
    _txActionCubit.close();
    _txFilterCubit.close();
    _txFormCubit.close();
    _goalCubit.close();
    _insightsCubit.close();
    _streakCubit.close();
    _notifCubit.close();
    super.dispose();
  }

  void _onTap(int index) => context.read<TabNavigationCubit>().setTab(index);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _txActionCubit),
        BlocProvider.value(value: _txFilterCubit),
        BlocProvider.value(value: _txFormCubit),
        BlocProvider.value(value: _goalCubit),
        BlocProvider.value(value: _insightsCubit),
        BlocProvider.value(value: _streakCubit),
        BlocProvider.value(value: _notifCubit),
        BlocProvider.value(value: _categoryCubit),
        BlocProvider.value(value: _recurringCubit),
      ],
      child: BlocBuilder<TabNavigationCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            body: MultiBlocListener(
              listeners: [
                BlocListener<TransactionActionCubit, TransactionActionState>(
                  listener: (context, state) {
                    if (state is TransactionActionSuccess) {
                      _txFilterCubit.load();
                      _insightsCubit.loadInsights();
                      _streakCubit.loadStreak();
                      _notifCubit.load();
                    }
                  },
                ),
              ],
              child: IndexedStack(
                index: currentIndex,
                children: [
                  HomeScreen(onTabSwitch: _onTap),
                  const TransactionsScreen(),
                  const GoalsScreen(),
                  const InsightsScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),
            bottomNavigationBar: _buildNavBar(currentIndex),
          );
        },
      ),
    );
  }

  Widget _buildNavBar(int currentIndex) {
    final l10n = AppLocalizations.of(context)!;
    
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
            children: [
              _NavItem(
                icon: Iconsax.home,
                label: l10n.home,
                index: tabHome,
                current: currentIndex,
                onTap: _onTap,
              ),
              _NavItem(
                icon: Iconsax.receipt,
                label: l10n.transactions,
                index: tabTransactions,
                current: currentIndex,
                onTap: _onTap,
              ),
              _NavItem(
                icon: Iconsax.chart,
                label: l10n.goals,
                index: tabGoals,
                current: currentIndex,
                onTap: _onTap,
              ),
              _NavItem(
                icon: Iconsax.graph,
                label: l10n.insights,
                index: tabInsights,
                current: currentIndex,
                onTap: _onTap,
              ),
              _NavItem(
                icon: Iconsax.user,
                label: l10n.profile,
                index: tabProfile,
                current: currentIndex,
                onTap: _onTap,
              ),
            ].map((item) => Expanded(child: item)).toList(),
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
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
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
