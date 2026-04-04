import 'package:finance_companion/data/models/goal_model.dart';
import 'package:finance_companion/data/models/notification_model.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class NotificationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<Database> get _db async => await _dbHelper.database;

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  Future<void> add(NotificationModel n) async {
    final db = await _db;
    await db.insert(
      'notifications',
      n.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NotificationModel>> getAll() async {
    final db = await _db;
    final maps =
        await db.query('notifications', orderBy: 'createdAt DESC');
    return maps.map((m) => NotificationModel.fromMap(m)).toList();
  }

  Future<int> getUnreadCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE isRead = 0',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<void> markAllRead() async {
    final db = await _db;
    await db.update('notifications', {'isRead': 1});
  }

  Future<void> markRead(String id) async {
    final db = await _db;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete('notifications');
  }

  // ─── Smart alert generation ────────────────────────────────────────────────

  /// Call this after every transaction mutation to generate contextual alerts.
  Future<void> generateAlertsFromTransactions({
    required List<TransactionModel> transactions,
    required double monthlyBudget,
  }) async {
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

    if (monthlyBudget > 0) {
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
  }

  /// Generates alerts for approaching or completed goals.
  Future<void> generateAlertsFromGoals(List<GoalModel> goals) async {
    for (final goal in goals) {
      if (goal.isCompleted) {
        await _maybeAdd(
          type: NotificationType.goalCompleted,
          title: '🎉 Goal reached: ${goal.title}',
          body:
              'Congratulations! You\'ve reached your savings goal. Keep it up!',
        );
      } else if (goal.daysRemaining <= 7 && goal.daysRemaining > 0) {
        await _maybeAdd(
          type: NotificationType.goalDeadline,
          title: '⏰ Goal deadline approaching',
          body:
              '"${goal.title}" ends in ${goal.daysRemaining} day${goal.daysRemaining == 1 ? '' : 's'}.',
        );
      }
    }
  }

  /// Generates a streak milestone alert.
  Future<void> generateStreakAlert(int streak) async {
    if (streak == 3 || streak == 7 || streak == 14 || streak == 30) {
      await _maybeAdd(
        type: NotificationType.streakMilestone,
        title: '🔥 $streak-day no-spend streak!',
        body: streak == 7
            ? 'One full week without unnecessary spending. Incredible discipline!'
            : 'You\'re on a roll! Keep avoiding unnecessary expenses.',
      );
    }
  }

  /// Avoids duplicating the same notification type within 24 hours.
  Future<void> _maybeAdd({
    required NotificationType type,
    required String title,
    required String body,
  }) async {
    final db = await _db;
    final cutoff =
        DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
    final existing = await db.query(
      'notifications',
      where: 'type = ? AND createdAt > ?',
      whereArgs: [type.name, cutoff],
    );
    if (existing.isNotEmpty) return;

    await add(NotificationModel(
      id: _uuid.v4(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
    ));
  }
}