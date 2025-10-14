// lib/services/auth_service.dart

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'currentUser';
  static const String _isLoggedInKey = 'isLoggedIn';
  final _uuid = const Uuid();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// ==================== REGISTER ====================
  Future<void> register(String username, String email, String password) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': DateTime.now(),
      });

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      await prefs.setString('email', email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email already registered';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// ==================== LOGIN ====================
  Future<bool> login(String usernameOrEmail, String password) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: usernameOrEmail,
        password: password,
      );

      // Get user data from Firestore
      final userData = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final username = userData.data()?['username'] as String? ?? 'User';

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      await prefs.setString('email', usernameOrEmail);

      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Wrong password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// ==================== LOGOUT ====================
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// ==================== CHECK SESSION ====================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // ✅ Mengubah ini untuk mendapatkan email pengguna, bukan username
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  /// ==================== USER EXIST CHECK ====================
  Future<bool> _isUserExists(String username, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      return users.any((user) {
        try {
          final userData = User.fromJson(jsonDecode(user));
          return userData.username == username || userData.email == email;
        } catch (e) {
          return false;
        }
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> isUserRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_usersKey) ?? [];

    return users.any((user) {
      try {
        final userData = User.fromJson(jsonDecode(user));
        return userData.email == email;
      } catch (e) {
        return false;
      }
    });
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString(_currentUserKey);
    final users = prefs.getStringList(_usersKey) ?? [];

    if (currentUserEmail == null) return null;

    for (var user in users) {
      try {
        final userData = User.fromJson(jsonDecode(user));
        if (userData.email == currentUserEmail) {
          return {
            'username': userData.username,
            'email': userData.email,
          };
        }
      } catch (e) {
        // skip jika data rusak
      }
    }

    return null;
  }

  /// ==================== RESET PASSWORD ====================
  Future<String> generateResetToken(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user exists
      if (!await isUserRegistered(email)) {
        throw Exception('No account found with this email');
      }

      final resetToken = _uuid.v4();
      await prefs.setString(
        'reset_token_$email',
        jsonEncode({
          'token': resetToken,
          'expires':
              DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        }),
      );

      return resetToken;
    } catch (e) {
      throw Exception('Failed to generate reset token: ${e.toString()}');
    }
  }

  Future<void> resetPassword(
      String email, String token, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Verify token
      final storedTokenJson = prefs.getString('reset_token_$email');
      if (storedTokenJson == null) {
        throw Exception('Invalid or expired reset token');
      }

      final tokenData = jsonDecode(storedTokenJson);
      final storedToken = tokenData['token'];
      final expiryDate = DateTime.parse(tokenData['expires']);

      if (token != storedToken || DateTime.now().isAfter(expiryDate)) {
        throw Exception('Invalid or expired reset token');
      }

      // Update password
      final users = prefs.getStringList(_usersKey) ?? [];
      final userIndex = users.indexWhere((user) {
        final userData = User.fromJson(jsonDecode(user));
        return userData.email == email;
      });

      if (userIndex == -1) {
        throw Exception('User not found');
      }

      final userData = User.fromJson(jsonDecode(users[userIndex]));
      final updatedUser = User(
        email: userData.email,
        password: newPassword,
        username: userData.username,
      );

      users[userIndex] = jsonEncode(updatedUser.toJson());
      await prefs.setStringList(_usersKey, users);

      // Clean up reset token
      await prefs.remove('reset_token_$email');
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  /// ==================== HELPERS ====================
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<void> clearUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
  }
}