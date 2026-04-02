import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _loggedInUserKey = 'logged_in_user_id';

  // ─── Password Hashing ────────────────────────────

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ─── Register ────────────────────────────────────

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required double initialBalance,
    String? imagePath,
  }) async {
    final db = await _dbHelper.database;

    // Check if email exists
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (existing.isNotEmpty) {
      throw Exception('Email already registered');
    }

    final user = UserModel(
      name: name.trim(),
      email: email.toLowerCase().trim(),
      passwordHash: _hashPassword(password),
      initialBalance: initialBalance,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    final id = await db.insert('users', user.toMap());
    final newUser = user.copyWith(id: id);

    // Save session
    await _saveSession(id);
    return newUser;
  }

  // ─── Login ───────────────────────────────────────

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );

    if (results.isEmpty) {
      throw Exception('No account found with this email');
    }

    final user = UserModel.fromMap(results.first);
    if (user.passwordHash != _hashPassword(password)) {
      throw Exception('Incorrect password');
    }

    await _saveSession(user.id!);
    return user;
  }

  // ─── Session ─────────────────────────────────────

  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_loggedInUserKey, userId);
  }

  Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_loggedInUserKey);
    if (userId == null) return null;

    final db = await _dbHelper.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserKey);
  }

  Future<void> updateProfile(UserModel user) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}