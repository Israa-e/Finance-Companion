import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _userCollection =>
      _firestore.collection('users');

  static const String _loggedInUserKey = 'logged_in_user_id';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required double initialBalance,
    double monthlyBudget = 0.0,
    String? imagePath,
  }) async {
    final db = await _dbHelper.database;
    final normalizedEmail = email.toLowerCase().trim();

    // Check local existing user first
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (existing.isNotEmpty) {
      throw Exception('An account with this email already exists');
    }

    final user = UserModel(
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      initialBalance: initialBalance,
      monthlyBudget: monthlyBudget,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    // Try Firebase if available, but don't block registration if it fails (Offline-First)
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        await _userCollection.doc(firebaseUser.uid).set({
          'name': user.name,
          'email': user.email,
          'initialBalance': user.initialBalance,
          'monthlyBudget': user.monthlyBudget,
          'imagePath': user.imagePath,
          'createdAt': user.createdAt.toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('[AuthRepository] Firebase registration skipped/failed: $e');
      // We continue since we want the app to be functional even without Firebase config
    }

    final id = await db.insert('users', user.toMap());
    final newUser = user.copyWith(id: id);
    await _saveSession(id);
    return newUser;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();

    // Try Firebase if available
    try {
      await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } catch (e) {
      debugPrint('[AuthRepository] Firebase login skipped/failed: $e');
      // If Firebase fails (no config or offline), we'll try local auth below
    }

    final user = await _ensureLocalUser(normalizedEmail, password);
    await _saveSession(user.id!);
    return user;
  }

  // Updated to handle local password verification if Firebase is unavailable
  Future<UserModel> _ensureLocalUser(String normalizedEmail, [String? password]) async {
    final db = await _dbHelper.database;

    final local = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (local.isNotEmpty) {
      final user = UserModel.fromMap(local.first);
      // If password provided, verify it (since we might be offline)
      if (password != null && user.passwordHash != _hashPassword(password)) {
        throw Exception('Incorrect password');
      }
      return user;
    }

    // If not local, try fetching from Firestore (only if Firebase user exists)
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw Exception('No account found with this email');
    }

    try {
      final querySnapshot = await _userCollection
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final user = UserModel(
          name: data['name'] as String,
          email: normalizedEmail,
          passwordHash: _hashPassword(password ?? ''), 
          initialBalance: (data['initialBalance'] as num).toDouble(),
          monthlyBudget: (data['monthlyBudget'] as num?)?.toDouble() ?? 0.0,
          imagePath: data['imagePath'] as String?,
          createdAt: DateTime.parse(data['createdAt'] as String),
        );

        final id = await db.insert('users', user.toMap());
        return user.copyWith(id: id);
      }
    } catch (e) {
      debugPrint('[AuthRepository] Firestore fetch failed: $e');
    }

    throw Exception('No account found with this email');
  }

  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_loggedInUserKey, userId);
  }

  Future<UserModel?> getLoggedInUser() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser?.email != null) {
      try {
        return await _ensureLocalUser(
          firebaseUser!.email!.toLowerCase().trim(),
        );
      } catch (e) {
        // Firestore sync failed (e.g. offline first launch).
        // Fall through to the local prefs lookup below.
        // We log the error so it appears in debug output.
        debugPrint('[AuthRepository] getLoggedInUser sync error: $e');
      }
    }

    // Fallback: local prefs session (offline / no Firebase user)
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
    await _auth.signOut();
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

    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await _userCollection.doc(firebaseUser.uid).set({
        'name': user.name,
        'email': user.email,
        'initialBalance': user.initialBalance,
        'monthlyBudget': user.monthlyBudget,
        'imagePath': user.imagePath,
        'createdAt': user.createdAt.toIso8601String(),
      }, SetOptions(merge: true));
    }
  }
}