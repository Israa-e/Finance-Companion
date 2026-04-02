import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _userCollection =>
      _firestore.collection('users');

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
    final normalizedEmail = email.toLowerCase().trim();

    // Register the user in Firebase Auth first
    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('Registration failed');
    }

    // Check if email exists in local app profile store
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (existing.isNotEmpty) {
      await firebaseUser.delete();
      throw Exception('Email already registered');
    }

    final user = UserModel(
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      initialBalance: initialBalance,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    // Save profile to Firestore
    try {
      await _userCollection.doc(firebaseUser.uid).set({
        'name': user.name,
        'email': user.email,
        'initialBalance': user.initialBalance,
        'imagePath': user.imagePath,
        'createdAt': user.createdAt.toIso8601String(),
      });
    } catch (e) {
      await firebaseUser.delete();
      throw Exception('Registration failed');
    }

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
    final normalizedEmail = email.toLowerCase().trim();
    try {
      await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email');
      }
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect password');
      }
      throw Exception(e.message ?? 'Login failed');
    }

    final user = await getLoggedInUser();
    if (user == null) {
      throw Exception('No local profile found for this account');
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
    final db = await _dbHelper.database;
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null && firebaseUser.email != null) {
      final normalizedEmail = firebaseUser.email!.toLowerCase().trim();
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [normalizedEmail],
      );
      if (results.isNotEmpty) {
        return UserModel.fromMap(results.first);
      }

      final firestoreDoc = await _userCollection.doc(firebaseUser.uid).get();
      if (firestoreDoc.exists) {
        final data = firestoreDoc.data()!;
        final user = UserModel(
          name: data['name'] as String,
          email: normalizedEmail,
          passwordHash: _hashPassword(''),
          initialBalance: (data['initialBalance'] as num).toDouble(),
          imagePath: data['imagePath'] as String?,
          createdAt: DateTime.parse(data['createdAt'] as String),
        );
        final id = await db.insert('users', user.toMap());
        final newUser = user.copyWith(id: id);
        await _saveSession(id);
        return newUser;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_loggedInUserKey);
    if (userId == null) return null;

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
        'imagePath': user.imagePath,
        'createdAt': user.createdAt.toIso8601String(),
      }, SetOptions(merge: true));
    }
  }
}
