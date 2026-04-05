import 'package:finance_companion/data/services/database_helper.dart';
import 'package:finance_companion/data/models/category_model.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<CategoryModel>> getAll(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'userId IS NULL OR userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  Future<void> insert(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.insert('categories', category.toMap());
  }

  Future<void> update(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static String generateId() => const Uuid().v4();
}
