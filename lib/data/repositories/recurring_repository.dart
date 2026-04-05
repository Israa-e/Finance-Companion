import 'package:finance_companion/data/services/database_helper.dart';
import 'package:finance_companion/data/models/recurring_transaction_model.dart';
import 'package:uuid/uuid.dart';

class RecurringRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<RecurringTransactionModel>> getAll(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_templates',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'nextDate ASC',
    );
    return List.generate(maps.length, (i) => RecurringTransactionModel.fromMap(maps[i]));
  }

  Future<void> insert(RecurringTransactionModel template) async {
    final db = await _dbHelper.database;
    await db.insert('recurring_templates', template.toMap());
  }

  Future<void> update(RecurringTransactionModel template) async {
    final db = await _dbHelper.database;
    await db.update(
      'recurring_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'recurring_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static String generateId() => const Uuid().v4();
}
