import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  
Future<void> _createDB(Database db, int version) async {
  // Users table 
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      passwordHash TEXT NOT NULL,
      initialBalance REAL NOT NULL DEFAULT 0,
      imagePath TEXT,
      createdAt TEXT NOT NULL
    )
  ''');

  // Transactions table 
  await db.execute('''
    CREATE TABLE transactions (
      id TEXT PRIMARY KEY,
      userId INTEGER NOT NULL,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      date TEXT NOT NULL,
      title TEXT NOT NULL,
      note TEXT,
      FOREIGN KEY (userId) REFERENCES users(id)
    )
  ''');

  // Goals table
  await db.execute('''
    CREATE TABLE goals (
      id TEXT PRIMARY KEY,
      userId INTEGER NOT NULL,
      title TEXT NOT NULL,
      targetAmount REAL NOT NULL,
      savedAmount REAL NOT NULL,
      startDate TEXT NOT NULL,
      endDate TEXT NOT NULL,
      status TEXT NOT NULL,
      emoji TEXT,
      FOREIGN KEY (userId) REFERENCES users(id)
    )
  ''');
}
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}