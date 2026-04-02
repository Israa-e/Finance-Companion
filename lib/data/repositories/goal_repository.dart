import 'package:finance_companion/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../models/goal_model.dart';

class GoalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

  Future<void> add(GoalModel goal) async {
    final db = await _db;
    await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GoalModel>> getAll(int userId) async {
    final db = await _db;
    final maps = await db.query(
      'goals',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((m) => GoalModel.fromMap(m)).toList();
  }

  Future<List<GoalModel>> getActive(int userId) async {
    final db = await _db;
    final maps = await db.query(
      'goals',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, 'active'],
    );
    return maps.map((m) => GoalModel.fromMap(m)).toList();
  }

  Future<void> update(GoalModel goal) async {
    final db = await _db;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addToSavings(String id, double amount) async {
    final db = await _db;

    // Get current goal
    final maps = await db.query('goals', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return;

    final goal = GoalModel.fromMap(maps.first);
    final newSaved = goal.savedAmount + amount;
    final newStatus = newSaved >= goal.targetAmount
        ? GoalStatus.completed
        : goal.status;

    await db.update(
      'goals',
      {'savedAmount': newSaved, 'status': newStatus.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
