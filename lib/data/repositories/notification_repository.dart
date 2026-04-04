import 'package:finance_companion/data/models/notification_model.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Repository responsible for simple CRUD operations on the 
/// notification log. Does NOT contain generation logic.
class NotificationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

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
}