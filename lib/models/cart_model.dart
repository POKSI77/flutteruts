import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book.dart';

class CartItem {
  final String id;
  final String title;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        title: json['title'],
        image: json['image'],
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'price': price,
        'quantity': quantity,
      };
}

class CartModel with ChangeNotifier {
  List<CartItem> _items = [];
  String? _currentUserKey; // ✅ Mengubah nama variabel

  List<CartItem> get items => _items;

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get itemCount => _items.length;

  /// Set email user saat login (agar data cart spesifik user)
  void setUserKey(String? email) { // ✅ Mengubah nama metode
    if (email != null) {
      _currentUserKey = 'cart_${email.replaceAll("@", "_")}';
    } else {
      _currentUserKey = null;
    }
    loadCart(); // ✅ Memuat data segera setelah kunci disetel
  }

  /// Load cart dari SharedPreferences
  Future<void> loadCart() async {
    if (_currentUserKey == null) {
      _items = [];
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_currentUserKey!);

    if (data != null) {
      final decoded = json.decode(data) as List;
      _items = decoded.map((e) => CartItem.fromJson(e)).toList();
    } else {
      _items = [];
    }
    notifyListeners();
  }

  /// Simpan cart ke SharedPreferences
  Future<void> saveCart() async {
    if (_currentUserKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _currentUserKey!,
      json.encode(_items.map((e) => e.toJson()).toList()),
    );
  }

  /// Tambahkan item dari objek Book
  Future<void> addItem(Book book) async {
    final existingItemIndex = _items.indexWhere((item) => item.id == book.id);
    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += 1;
    } else {
      _items.add(CartItem(
        id: book.id,
        title: book.title,
        image: book.imageUrl,
        price: book.getDisplayPriceValue(),
      ));
    }
    await saveCart();
    notifyListeners();
  }

  /// Hapus item dari cart
  Future<void> removeItem(Book book) async {
    _items.removeWhere((item) => item.id == book.id);
    await saveCart();
    notifyListeners();
  }

  /// Kurangi quantity item
  Future<void> decrementQuantity(Book book) async {
    final existingItemIndex = _items.indexWhere((item) => item.id == book.id);
    if (existingItemIndex >= 0) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity--;
      } else {
        _items.removeAt(existingItemIndex);
      }
      await saveCart();
      notifyListeners();
    }
  }

  /// Kosongkan seluruh cart
  Future<void> clearCart() async {
    _items.clear();
    if (_currentUserKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey!);
    }
    notifyListeners();
  }
}