import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<Database> get _db async => await _dbHelper.database;

  CollectionReference<Map<String, dynamic>>? get _transactionsRef {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
      return _firestore.collection('users').doc(uid).collection('transactions');
    } catch (_) {
      return null;
    }
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  /// Per-record upsert — avoids destructive delete-all.
  Future<void> _cacheRemoteTransactions(
    List<TransactionModel> transactions,
  ) async {
    final db = await _db;

    final existing =
        await db.query('transactions', columns: ['id', 'lastUpdated']);
    final existingIds = <String>{};
    final localTimestamps = <String, DateTime>{};
    for (final r in existing) {
      final id = r['id'] as String;
      existingIds.add(id);
      final lastUpStr = r['lastUpdated'] as String?;
      if (lastUpStr != null && lastUpStr.isNotEmpty) {
        localTimestamps[id] = DateTime.parse(lastUpStr);
      }
    }
    final remoteIds = transactions.map((t) => t.id).toSet();

    // Remove local records that no longer exist remotely and aren't pending deletes
    final toDelete = existingIds.difference(remoteIds);
    for (final id in toDelete) {
      await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    }

    for (final t in transactions) {
      final localTime = localTimestamps[t.id];
      if (localTime == null || t.lastUpdated.isAfter(localTime)) {
        await db.insert(
          'transactions',
          t.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  // ── Sync ─────────────────────────────────────────────────────────────────

  /// Push unsynced changes (adds/updates) and soft-delete records to Firestore.
  Future<void> syncLocalChanges() async {
    final db = await _db;
    final ref = _transactionsRef;
    if (ref == null) return;

    final localChanges = await db.query(
      'transactions',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    for (final map in localChanges) {
      final t = TransactionModel.fromMap(map);
      try {
        if (t.isDeleted) {
          // Propagate soft-delete to Firestore, then hard-delete locally
          await ref.doc(t.id).delete();
          await db.delete('transactions', where: 'id = ?', whereArgs: [t.id]);
        } else {
          await ref.doc(t.id).set(t.toMap());
          await db.update(
            'transactions',
            {'isSynced': 1},
            where: 'id = ?',
            whereArgs: [t.id],
          );
        }
      } catch (_) {
        // Still offline — will retry on next sync
      }
    }
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<void> add(TransactionModel t) async {
    final db = await _db;
    final ref = _transactionsRef;

    bool synced = false;
    if (ref != null) {
      try {
        await ref.doc(t.id).set(t.toMap());
        synced = true;
      } catch (_) {
        synced = false;
      }
    }

    await db.insert(
      'transactions',
      t.copyWith(isSynced: synced).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns all non-deleted transactions, newest first.
  Future<List<TransactionModel>> getAll() async {
    final ref = _transactionsRef;
    if (ref == null) {
      // Offline / unauthenticated — serve from local cache, excluding soft-deletes
      final db = await _db;
      final maps = await db.query(
        'transactions',
        where: 'isDeleted = ?',
        whereArgs: [0],
        orderBy: 'date DESC',
      );
      return maps.map((m) => TransactionModel.fromMap(m)).toList();
    }

    // Attempt to push pending changes (including pending deletes) before fetching
    await syncLocalChanges();

    try {
      final snapshot = await ref.orderBy('date', descending: true).get();
      final transactions = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        data['userId'] = data['userId'] ?? -1;
        return TransactionModel.fromMap(data);
      }).toList();

      await _cacheRemoteTransactions(transactions);
      return transactions;
    } catch (_) {
      // Firestore unavailable — serve from local cache, excluding soft-deletes
      final db = await _db;
      final maps = await db.query(
        'transactions',
        where: 'isDeleted = ?',
        whereArgs: [0],
        orderBy: 'date DESC',
      );
      return maps.map((m) => TransactionModel.fromMap(m)).toList();
    }
  }

  Future<void> update(TransactionModel t) async {
    final db = await _db;
    final ref = _transactionsRef;

    bool synced = false;
    if (ref != null) {
      try {
        await ref.doc(t.id).set(t.toMap());
        synced = true;
      } catch (_) {
        synced = false;
      }
    }

    await db.update(
      'transactions',
      t.copyWith(isSynced: synced).toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  /// Soft-delete: marks the record locally as isDeleted=true, isSynced=false.
  /// On next [syncLocalChanges] call, the Firestore document is deleted and
  /// the local record is hard-deleted. This ensures offline deletes are never lost.
  Future<void> delete(String id) async {
    final db = await _db;
    final ref = _transactionsRef;

    if (ref != null) {
      // Online: delete immediately from Firestore and locally
      try {
        await ref.doc(id).delete();
        await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
        return;
      } catch (_) {
        // Offline — fall through to soft-delete
      }
    }

    // Offline or unauthenticated: soft-delete so the delete syncs on reconnect
    await db.update(
      'transactions',
      {'isDeleted': 1, 'isSynced': 0, 'lastUpdated': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Aggregates (FIX: reuse already-fetched list — no extra DB calls) ──────

  Future<double> getTotalIncome() async {
    final transactions = await getAll();
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (total, t) => total + t.amount);
  }

  Future<double> getTotalExpense() async {
    final transactions = await getAll();
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (total, t) => total + t.amount);
  }

  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    return income - expense;
  }

  Future<List<TransactionModel>> getThisMonth() async {
    final transactions = await getAll();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return transactions
        .where(
          (t) =>
              !t.date.isBefore(start) &&
              t.date.isBefore(end),
        )
        .toList();
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final transactions = await getAll();
    final Map<String, double> result = {};
    for (final t in transactions.where(
      (t) => t.type == TransactionType.expense,
    )) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  Future<Map<String, double>> getWeeklyExpenses() async {
    final transactions = await getAll();
    final Map<String, double> map = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final key = '${day.day}/${day.month}';
      map[key] = transactions
          .where((t) => t.type == TransactionType.expense)
          .where(
            (t) =>
                !t.date.isBefore(start) &&
                t.date.isBefore(end),
          )
          .fold<double>(0.0, (total, t) => total + t.amount);
    }
    return map;
  }

  Future<List<TransactionModel>> search(String query) async {
    final transactions = await getAll();
    final q = query.toLowerCase();
    return transactions
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q) ||
              (t.note?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  Future<double> getMonthlyExpense(DateTime month) async {
    final transactions = await getAll();
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .where(
          (t) =>
              !t.date.isBefore(start) &&
              t.date.isBefore(end),
        )
        .fold<double>(0.0, (total, t) => total + t.amount);
  }
}
