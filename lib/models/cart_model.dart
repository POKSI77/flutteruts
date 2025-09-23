// lib/models/cart_model.dart

import 'package:flutter/foundation.dart';
import 'book.dart';

class CartModel extends ChangeNotifier {
  final List<Book> _items = [];

  List<Book> get items => List.unmodifiable(_items);

  void addItem(Book book) {
    // Periksa apakah buku sudah ada di keranjang
    bool itemExists = false;
    for (var item in _items) {
      if (item.id == book.id) {
        // Jika buku sudah ada, tambahkan kuantitasnya
        item.quantity++;
        itemExists = true;
        break;
      }
    }

    // Jika buku belum ada, tambahkan sebagai item baru dengan kuantitas 1
    if (!itemExists) {
      _items.add(Book(
        id: book.id,
        title: book.title,
        author: book.author,
        price: book.price,
        imageUrl: book.imageUrl,
        description: book.description,
        quantity: 1, // Kuantitas awal 1
      ));
    }

    notifyListeners();
  }

    void incrementQuantity(Book book) {
    final existingBook = _items.firstWhere((item) => item.id == book.id);
    if (existingBook != null) {
      existingBook.setQuantity(existingBook.quantity + 1);
      notifyListeners();
    }
  }
  void decrementQuantity(Book book) {
    final existingBook = _items.firstWhere((item) => item.id == book.id);
    if (existingBook != null && existingBook.quantity > 1) {
      existingBook.setQuantity(existingBook.quantity - 1);
      notifyListeners();
    }
  }
  void removeItem(Book book) {
    _items.remove(book);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}