// lib/models/special_book_model.dart

import 'package:flutter/foundation.dart';
import 'book.dart';

class SpecialBookModel extends ChangeNotifier {
  final List<Book> _specialItems = [];

  List<Book> get items => List.unmodifiable(_specialItems);

  void addItem(Book book) {
    if (!_specialItems.contains(book)) {
      _specialItems.add(book);
      notifyListeners();
    }
  }

  void removeItem(Book book) {
    _specialItems.remove(book);
    notifyListeners();
  }
}