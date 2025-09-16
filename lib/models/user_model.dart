import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String username;
  final String email;
  final String password;

  User({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}

class AuthService {
  final String _usersKey = 'users';

  Future<void> register(String username, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      // Validate username
      if (username.length < 3) {
        throw Exception('Username must be at least 3 characters');
      }

      // Validate password
      if (!_isValidPassword(password)) {
        throw Exception('Password must be at least 6 characters');
      }

      // Check if username or email already exists
      final isExisting = await isUserExists(username, email);
      if (isExisting) {
        throw Exception('Username or email already registered');
      }

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

  Future<bool> login(String usernameOrEmail, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList(_usersKey) ?? [];

      return users.any((user) {
        try {
          final userData = User.fromJson(jsonDecode(user));
          return (userData.username == usernameOrEmail ||
                  userData.email == usernameOrEmail) &&
              userData.password == password;
        } catch (e) {
          return false;
        }
      });
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<bool> isUserExists(String username, String email) async {
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
      throw Exception('Check user exists failed: ${e.toString()}');
    }
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }
}
