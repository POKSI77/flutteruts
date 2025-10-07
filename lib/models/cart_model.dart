// lib/models/cart_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book.dart';

class CartModel extends ChangeNotifier {
  final List<Book> _items = [];
  String _currentUserEmail = "guest"; // default guest

  List<Book> get items => List.unmodifiable(_items);

  CartModel() {
    // default load "guest" cart
    _loadCart();
  }

  /// Set email user aktif
  void setUserEmail(String email) {
    _currentUserEmail = email.isNotEmpty ? email : "guest";
    _loadCart(); // reload cart sesuai akun
  }

  /// Tambah item ke cart
  void addItem(Book book) {
    try {
      final existingBook = _items.firstWhere(
        (item) => item.id == book.id,
        orElse: () => Book(
          id: '',
          title: '',
          author: '',
          price: 0,
          imageUrl: '',
          description: '',
        ),
      );

      if (existingBook.id.isNotEmpty) {
        existingBook.setQuantity(existingBook.quantity + 1);
      } else {
        _items.add(book.copyWith(quantity: 1));
      }

      _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint("Error addItem: $e");
    }
  }

  /// Tambah jumlah
  void incrementQuantity(Book book) {
    final existingBook = _items.firstWhere((item) => item.id == book.id);
    existingBook.setQuantity(existingBook.quantity + 1);
    _saveCart();
    notifyListeners();
  }

  /// Kurangi jumlah
  void decrementQuantity(Book book) {
    final existingBook = _items.firstWhere((item) => item.id == book.id);
    if (existingBook.quantity > 1) {
      existingBook.setQuantity(existingBook.quantity - 1);
    } else {
      _items.remove(existingBook);
    }
    _saveCart();
    notifyListeners();
  }

  /// Hapus 1 item
  void removeItem(Book book) {
    _items.removeWhere((item) => item.id == book.id);
    _saveCart();
    notifyListeners();
  }

  /// Hapus semua isi cart
  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  /// 🔹 Simpan cart ke SharedPreferences (per akun/email)
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(_items.map((b) => b.toJson()).toList());
    await prefs.setString('cart_items_${_currentUserEmail}', cartJson);
  }

  /// 🔹 Load cart dari SharedPreferences (per akun/email)
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart_items_${_currentUserEmail}');
    _items.clear();

    if (cartString != null) {
      final List<dynamic> decoded = jsonDecode(cartString);
      _items.addAll(decoded.map((b) => Book.fromJson(b)).toList());
    }

    notifyListeners();
  }
}
