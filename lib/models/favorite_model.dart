// lib/models/favorite_model.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'book.dart';

class FavoriteModel extends ChangeNotifier {
  List<Book> _favorites = [];
  String? _currentUserKey;

  List<Book> get favorites => List.unmodifiable(_favorites);

  /// Mengatur user aktif saat ini dan memuat data
  Future<void> setUser(String usernameOrEmail) async { // ✅ Jadikan async
    _currentUserKey = _generateUserKey(usernameOrEmail);
    await loadFavorites(); // ✅ Pastikan ini diawait
  }

  /// Membuat key unik untuk tiap user
  String _generateUserKey(String usernameOrEmail) {
    return 'favorites_${usernameOrEmail.replaceAll("@", "_")}';
  }

  /// Mengecek apakah buku termasuk favorit
  bool isFavorite(Book book) {
    if (_currentUserKey == null) return false;
    return _favorites.any((b) => b.id == book.id);
  }

  /// Menambah buku ke favorit
  Future<void> addFavorite(Book book) async {
    if (!isFavorite(book)) {
      _favorites.add(book);
      await saveFavorites();
      notifyListeners();
    }
  }

  /// Menghapus buku dari favorit
  Future<void> removeFavorite(Book book) async {
    _favorites.removeWhere((b) => b.id == book.id);
    await saveFavorites();
    notifyListeners();
  }

  /// Menyimpan daftar favorit ke SharedPreferences
  Future<void> saveFavorites() async {
    if (_currentUserKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    final favoriteList =
        _favorites.map((book) => json.encode(book.toJson())).toList();
    await prefs.setStringList(_currentUserKey!, favoriteList);
  }

  /// Memuat daftar favorit dari SharedPreferences
  Future<void> loadFavorites() async {
    if (_currentUserKey == null) {
      _favorites = [];
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final favoriteList = prefs.getStringList(_currentUserKey!) ?? [];
    _favorites = favoriteList
        .map((item) => Book.fromJson(json.decode(item)))
        .toList();
    notifyListeners();
  }

  /// Menghapus semua favorit user aktif
  Future<void> clearFavorites() async {
    _favorites.clear();
    if (_currentUserKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey!);
    }
    notifyListeners();
  }
}