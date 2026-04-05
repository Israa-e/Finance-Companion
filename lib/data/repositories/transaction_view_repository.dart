import 'package:finance_companion/data/models/transaction_view_model.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TransactionViewRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<TransactionView>> getAll(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transaction_views',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => TransactionView.fromMap(map)).toList();
  }

  Future<void> add(TransactionView view) async {
    final db = await _dbHelper.database;
    await db.insert(
      'transaction_views',
      view.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'transaction_views',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
