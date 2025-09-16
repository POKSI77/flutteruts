import 'package:flutter/foundation.dart';
import 'book.dart';

class CartModel extends ChangeNotifier {
  final List<Book> _items = [];

  List<Book> get items => List.unmodifiable(_items);

  double get totalPrice => _items.fold(0, (total, book) => total + book.price);

  void addItem(Book book) {
    _items.add(book);
    notifyListeners();
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
