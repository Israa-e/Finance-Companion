import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        fileName,
        version: 11,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 11,
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
        categoryBudgets TEXT,
        biometricEnabled INTEGER NOT NULL DEFAULT 0,
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
        isSynced INTEGER NOT NULL DEFAULT 1,
        isDeleted INTEGER NOT NULL DEFAULT 0,
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

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconCode INTEGER NOT NULL,
        colorValue INTEGER NOT NULL,
        type TEXT NOT NULL, -- 'income' or 'expense'
        userId INTEGER, -- null for system categories
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_templates (
        id TEXT PRIMARY KEY,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        frequency TEXT NOT NULL, -- 'daily', 'weekly', 'monthly'
        nextDate TEXT NOT NULL,
        lastApplied TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    await _createNotificationsTable(db);
    await _createSavedViewsTable(db);
    await _seedDefaultCategories(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createNotificationsTable(db);
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN monthlyBudget REAL NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN lastUpdated TEXT NOT NULL DEFAULT ""');
    }
    if (oldVersion < 4) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN currency TEXT NOT NULL DEFAULT "USD"');
    }
    if (oldVersion < 5) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN warningThreshold REAL NOT NULL DEFAULT 0.8');
      await db.execute(
          'ALTER TABLE users ADD COLUMN criticalThreshold REAL NOT NULL DEFAULT 1.0');
    }
    if (oldVersion < 6) {
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN isSynced INTEGER NOT NULL DEFAULT 1');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE users ADD COLUMN categoryBudgets TEXT');
      await db.execute(
          'ALTER TABLE users ADD COLUMN biometricEnabled INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 8) {
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          iconCode INTEGER NOT NULL,
          colorValue INTEGER NOT NULL,
          type TEXT NOT NULL,
          userId INTEGER,
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE recurring_templates (
          id TEXT PRIMARY KEY,
          userId INTEGER NOT NULL,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          category TEXT NOT NULL,
          note TEXT,
          frequency TEXT NOT NULL,
          nextDate TEXT NOT NULL,
          lastApplied TEXT,
          isActive INTEGER NOT NULL DEFAULT 1,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users(id)
        )
      ''');
      await _seedDefaultCategories(db);
    }
    if (oldVersion < 10) {
      await _createSavedViewsTable(db);
    }
    if (oldVersion < 11) {
      // Fix wrong Iconsax codepoints in system categories
      await db.delete('categories', where: 'userId IS NULL');
      await _seedDefaultCategories(db);
    }
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();
    // Codepoints verified from iconsax-0.0.8 package source
    final defaults = [
      ['Salary', 0xec7b, 0xFF4CAF50, 'income'], // wallet_money
      ['Investment', 0xe9b8, 0xFF2196F3, 'income'], // chart_2
      ['Gift', 0xea83, 0xFFFF9800, 'income'], // gift
      ['Freelance', 0xeb6e, 0xFF9C27B0, 'income'], // personalcard
      ['Food', 0xe9db, 0xFFFF5252, 'expense'], // coffee
      ['Rent', 0xeab8, 0xFF795548, 'expense'], // house
      ['Shopping', 0xebee, 0xFFE91E63, 'expense'], // shopping_bag
      ['Transport', 0xe9a5, 0xFF607D8B, 'expense'], // car
      ['Entertainment', 0xea7d, 0xFF673AB7, 'expense'], // game
      ['Bills', 0xeb93, 0xFFFFC107, 'expense'], // receipt_2
      ['Health', 0xeaa1, 0xFF00BCD4, 'expense'], // health
    ];

    for (var cat in defaults) {
      await db.insert('categories', {
        'id': 'system_${cat[3]}_${cat[0].toString().toLowerCase()}',
        'name': cat[0],
        'iconCode': cat[1],
        'colorValue': cat[2],
        'type': cat[3],
        'userId': null,
        'createdAt': now,
      });
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

  Future<void> _createSavedViewsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transaction_views (
        id TEXT PRIMARY KEY,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        filter TEXT NOT NULL,
        searchQuery TEXT NOT NULL DEFAULT "",
        selectedCategories TEXT, -- JSON list of strings
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
