import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book.dart';

class FavoriteModel extends ChangeNotifier {
  final List<Book> _favorites = [];
  String _currentUserEmail = "guest"; // default guest

  List<Book> get favorites => List.unmodifiable(_favorites);

  FavoriteModel() {
    _loadFavorites(); // load awal
  }

  /// Set email user aktif
  void setUserEmail(String email) {
    _currentUserEmail = email.isNotEmpty ? email : "guest";
    _loadFavorites();
  }

  /// Tambah / hapus dari favorit
  void toggleFavorite(Book book) {
    final index = _favorites.indexWhere((b) => b.id == book.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(book.copyWith(quantity: 1));
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(Book book) {
    return _favorites.any((b) => b.id == book.id);
  }

  void clearFavorites() {
    _favorites.clear();
    _saveFavorites();
    notifyListeners();
  }

  /// 🔹 Simpan ke SharedPreferences (per akun)
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favJson = jsonEncode(_favorites.map((b) => b.toJson()).toList());
    await prefs.setString('favorites_${_currentUserEmail}', favJson);
  }

  /// 🔹 Load dari SharedPreferences (per akun)
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favString = prefs.getString('favorites_${_currentUserEmail}');
    _favorites.clear();

    if (favString != null) {
      final List<dynamic> decoded = jsonDecode(favString);
      _favorites.addAll(decoded.map((b) => Book.fromJson(b)).toList());
    }

    notifyListeners();
  }
}
