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

    // Register in Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('Registration failed');

    // Guard: email already exists locally
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (existing.isNotEmpty) {
      await firebaseUser.delete();
      throw Exception('An account with this email already exists');
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
    } catch (_) {
      await firebaseUser.delete();
      throw Exception('Registration failed — please try again');
    }

    final id = await db.insert('users', user.toMap());
    final newUser = user.copyWith(id: id);
    await _saveSession(id);
    return newUser;
  }

  // ─── Login ───────────────────────────────────────

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();

    // Step 1 — authenticate with Firebase
    try {
      await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email');
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Incorrect password');
        case 'too-many-requests':
          throw Exception('Too many attempts — please try again later');
        default:
          throw Exception(e.message ?? 'Login failed');
      }
    }

    // Step 2 — load or sync local profile
    final user = await _ensureLocalUser(normalizedEmail);
    await _saveSession(user.id!);
    return user;
  }

  // ─── Ensure local profile exists (sync from Firestore if needed) ─────────

  /// Looks up the local SQLite record for [email].
  /// If not found (new device / cleared storage), fetches from Firestore
  /// and inserts a local copy. Throws only if neither source has the record.
  Future<UserModel> _ensureLocalUser(String normalizedEmail) async {
    final db = await _dbHelper.database;

    // Fast path: local record exists
    final local = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (local.isNotEmpty) return UserModel.fromMap(local.first);

    // Slow path: sync from Firestore
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) throw Exception('Authentication error');

    final doc = await _userCollection.doc(firebaseUser.uid).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Account profile not found — please re-register');
    }

    final data = doc.data()!;
    final user = UserModel(
      name: data['name'] as String,
      email: normalizedEmail,
      passwordHash: _hashPassword(''), // hash not stored remotely — that's fine
      initialBalance: (data['initialBalance'] as num).toDouble(),
      imagePath: data['imagePath'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );

    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  // ─── Session ─────────────────────────────────────

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
      } catch (_) {
        // Local sync failed — fall through to prefs lookup
      }
    }

    // Fallback: shared prefs session (offline / no Firebase user)
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
        'imagePath': user.imagePath,
        'createdAt': user.createdAt.toIso8601String(),
      }, SetOptions(merge: true));
    }
  }
}
