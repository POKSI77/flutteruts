import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'book.dart';

class FavoriteModel extends ChangeNotifier {
  List<Book> _favorites = [];
  String? _currentUserKey;

  List<Book> get favorites => List.unmodifiable(_favorites);

  Future<void> setUser(String usernameOrEmail) async {
    _currentUserKey = _generateUserKey(usernameOrEmail);
    await loadFavorites();
  }

  String _generateUserKey(String usernameOrEmail) {
    return 'favorites_${usernameOrEmail.replaceAll("@", "_")}';
  }

  bool isFavorite(Book book) {
    if (_currentUserKey == null) return false;
    return _favorites.any((b) => b.id == book.id);
  }

  Future<void> addFavorite(Book book) async {
    if (!isFavorite(book)) {
      _favorites.add(book);
      await saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(Book book) async {
    _favorites.removeWhere((b) => b.id == book.id);
    await saveFavorites();
    notifyListeners();
  }

  Future<void> saveFavorites() async {
    if (_currentUserKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    final favoriteList =
        _favorites.map((book) => json.encode(book.toJson())).toList();
    await prefs.setStringList(_currentUserKey!, favoriteList);
  }

  Future<void> loadFavorites() async {
    if (_currentUserKey == null) {
      _favorites = [];
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final favoriteList = prefs.getStringList(_currentUserKey!) ?? [];
    _favorites =
        favoriteList.map((item) => Book.fromJson(json.decode(item))).toList();
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    if (_currentUserKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey!);
    }
    notifyListeners();
  }
}
