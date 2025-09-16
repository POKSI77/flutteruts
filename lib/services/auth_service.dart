import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'currentUser';
  final _uuid = const Uuid();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// ==================== REGISTER ====================
  Future<void> register(String username, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      // Validate username
      if (username.isEmpty || username.length < 3) {
        throw Exception('Username must be at least 3 characters');
      }

      // Validate email format
      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password strength
      if (!_isValidPassword(password)) {
        throw Exception('Password must be at least 6 characters');
      }

      // Check if user already exists
      if (await _isUserExists(username, email)) {
        throw Exception('Username or email already registered');
      }

      // Add new user
      final newUser = User(
        username: username,
        email: email,
        password: password,
      );
      users.add(jsonEncode(newUser.toJson()));
      await prefs.setStringList(_usersKey, users);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// ==================== LOGIN ====================
  Future<bool> login(String usernameOrEmail, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      final matched = users.any((user) {
        try {
          final userData = User.fromJson(jsonDecode(user));
          return (userData.username == usernameOrEmail ||
                  userData.email == usernameOrEmail) &&
              userData.password == password;
        } catch (e) {
          return false;
        }
      });

      if (matched) {
        // simpan session
        await prefs.setString(_currentUserKey, usernameOrEmail);
      }

      return matched;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// ==================== LOGOUT ====================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// ==================== CHECK SESSION ====================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey) != null;
  }

  Future<String?> getCurrentUser() async {
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
