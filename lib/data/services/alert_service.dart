import 'package:finance_companion/data/models/goal_model.dart';
import 'package:finance_companion/data/models/notification_model.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/data/repositories/notification_repository.dart';
import 'package:finance_companion/data/services/notification_service.dart';
import 'package:uuid/uuid.dart';

/// Service responsible for business logic relating to smart alerts,
/// budget warnings, and goal milestones.
class AlertService {
  final NotificationRepository _notifRepo;
  final _uuid = const Uuid();

  AlertService(this._notifRepo);

  /// Checks the current monthly expense against a user budget.
  /// Fires a notification if threshold (90% or 100%) is exceeded.
  Future<void> checkBudgetAlerts({
    required List<TransactionModel> transactions,
    required double monthlyBudget,
  }) async {
    if (monthlyBudget <= 0) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final monthlyExpense = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(
                startOfMonth.subtract(const Duration(milliseconds: 1)),
              ),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final ratio = monthlyExpense / monthlyBudget;
    if (ratio >= 0.9) {
      await _maybeAdd(
        type: NotificationType.monthlyBudgetWarning,
        title: ratio >= 1.0
            ? '🚨 Monthly budget exceeded!'
            : '⚠️ 90% of monthly budget used',
        body: ratio >= 1.0
            ? 'You\'ve spent more than your monthly budget. Consider reviewing your expenses.'
            : 'You\'re close to your monthly limit. Spend carefully for the rest of the month.',
      );
    }
  }

  /// Checks if any goals are completed or reaching deadlines.
  Future<void> checkGoalAlerts(List<GoalModel> goals) async {
    for (final goal in goals) {
      if (goal.isCompleted) {
        await _maybeAdd(
          type: NotificationType.goalCompleted,
          title: '🎉 Goal reached: ${goal.title}',
          body: 'Congratulations! You\'ve reached your savings goal.',
        );
      } else if (goal.daysRemaining <= 7 && goal.daysRemaining > 0) {
        await _maybeAdd(
          type: NotificationType.goalDeadline,
          title: '⏰ Goal deadline approaching',
          body: '"${goal.title}" ends in ${goal.daysRemaining} days.',
        );
      }
    }
  }

  /// Checks if the current streak reaches a milestone.
  Future<void> checkStreakAlerts(int streak) async {
    if (streak == 3 || streak == 7 || streak == 14 || streak == 30) {
      await _maybeAdd(
        type: NotificationType.streakMilestone,
        title: '🔥 $streak-day no-spend streak!',
        body: streak == 7
            ? 'A full week without unnecessary spending. Great job!'
            : 'You\'re on a roll! Keep up the discipline.',
      );
    }
  }

  /// Adds a notification to the database and fires a system alert
  /// only if the same type hasn't been fired in the last 24 hours.
  Future<void> _maybeAdd({
    required NotificationType type,
    required String title,
    required String body,
  }) async {
    // Only fire if not already fired in the last 24h to avoid spam
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final existing = await _notifRepo.getAll();
    
    final duplicate = existing.any((n) => 
      n.type == type && 
      n.createdAt.isAfter(cutoff)
    );
    
    if (duplicate) return;

    // 1. Save to database log
    await _notifRepo.add(NotificationModel(
      id: _uuid.v4(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
    ));

    // 2. Fire actual system notification
    try {
      await NotificationService.instance.showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
      );
    } catch (_) {}
  }
}
