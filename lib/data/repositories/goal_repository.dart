import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../models/goal_model.dart';

class GoalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<Database> get _db async => await _dbHelper.database;

  CollectionReference<Map<String, dynamic>>? get _goalsRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('goals');
  }

  Future<void> _cacheRemoteGoals(List<GoalModel> goals) async {
    final db = await _db;
    await db.delete('goals');
    for (final goal in goals) {
      await db.insert(
        'goals',
        goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> add(GoalModel goal) async {
    final db = await _db;
    await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final ref = _goalsRef;
    if (ref != null) {
      await ref.doc(goal.id).set(goal.toMap());
    }
  }

  Future<List<GoalModel>> getAll(int userId) async {
    final ref = _goalsRef;
    if (ref == null) {
      final db = await _db;
      final maps = await db.query(
        'goals',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return maps.map((m) => GoalModel.fromMap(m)).toList();
    }

    final snapshot = await ref.get();
    final goals = snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      data['userId'] = data['userId'] ?? userId;
      return GoalModel.fromMap(data);
    }).toList();

    await _cacheRemoteGoals(goals);
    return goals;
  }

  Future<List<GoalModel>> getActive(int userId) async {
    final goals = await getAll(userId);
    return goals.where((goal) => goal.status == GoalStatus.active).toList();
  }

  Future<void> update(GoalModel goal) async {
    final db = await _db;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );

    final ref = _goalsRef;
    if (ref != null) {
      await ref.doc(goal.id).set(goal.toMap());
    }
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);

    final ref = _goalsRef;
    if (ref != null) {
      await ref.doc(id).delete();
    }
  }

  Future<void> addToSavings(String id, double amount) async {
    if (amount <= 0) return;

    final db = await _db;
    final maps = await db.query('goals', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return;

    final goal = GoalModel.fromMap(maps.first);
    if (amount > goal.remainingAmount) {
      throw Exception('Amount exceeds remaining goal total.');
    }

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

    final ref = _goalsRef;
    if (ref != null) {
      await ref.doc(id).update({
        'savedAmount': newSaved,
        'status': newStatus.name,
      });
    }
  }
}
