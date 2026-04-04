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
      version: 5, // Bumped to 5 to add budget alert thresholds
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        initialBalance REAL NOT NULL DEFAULT 0,
        monthlyBudget REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT "USD",
        warningThreshold REAL NOT NULL DEFAULT 0.8,
        criticalThreshold REAL NOT NULL DEFAULT 1.0,
        imagePath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

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
        lastUpdated TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

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

    await _createNotificationsTable(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createNotificationsTable(db);
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN monthlyBudget REAL NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE transactions ADD COLUMN lastUpdated TEXT NOT NULL DEFAULT ""');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users ADD COLUMN currency TEXT NOT NULL DEFAULT "USD"');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE users ADD COLUMN warningThreshold REAL NOT NULL DEFAULT 0.8');
      await db.execute('ALTER TABLE users ADD COLUMN criticalThreshold REAL NOT NULL DEFAULT 1.0');
    }
  }

  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}