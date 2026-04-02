import 'package:finance_companion/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

  // ─── CRUD ────────────────────────────────────────

  Future<void> add(TransactionModel t) async {
    final db = await _db;
    await db.insert(
      'transactions',
      t.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getAll() async {
    final db = await _db;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<void> update(TransactionModel t) async {
    final db = await _db;
    await db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Queries ─────────────────────────────────────

  Future<double> getTotalIncome() async {
    final db = await _db;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpense() async {
    final db = await _db;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    return income - expense;
  }

  Future<List<TransactionModel>> getThisMonth() async {
    final db = await _db;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 1).toIso8601String();
    final maps = await db.query(
      'transactions',
      where: "date >= ? AND date < ?",
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense'
      GROUP BY category
    ''');
    return {
      for (final row in result)
        row['category'] as String: (row['total'] as num).toDouble()
    };
  }

  Future<Map<String, double>> getWeeklyExpenses() async {
    final db = await _db;
    final Map<String, double> map = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day).toIso8601String();
      final end = DateTime(day.year, day.month, day.day + 1).toIso8601String();
      final key = '${day.day}/${day.month}';

      final result = await db.rawQuery('''
        SELECT SUM(amount) as total FROM transactions
        WHERE type = 'expense' AND date >= ? AND date < ?
      ''', [start, end]);

      map[key] = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    }
    return map;
  }

  Future<List<TransactionModel>> search(String query) async {
    final db = await _db;
    final q = '%$query%';
    final maps = await db.query(
      'transactions',
      where: 'title LIKE ? OR category LIKE ? OR note LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'date DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }
  Future<double> getMonthlyExpense(DateTime month) async {
  final db = await _db;
  final start = DateTime(month.year, month.month, 1).toIso8601String();
  final end = DateTime(month.year, month.month + 1, 1).toIso8601String();
  final result = await db.rawQuery('''
    SELECT SUM(amount) as total FROM transactions
    WHERE type = 'expense' AND date >= ? AND date < ?
  ''', [start, end]);
  return (result.first['total'] as num?)?.toDouble() ?? 0.0;
}
}