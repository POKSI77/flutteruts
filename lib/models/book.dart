// lib/models/book.dart

import 'package:flutter/foundation.dart';

class Book {
  final String id;
  String title;
  String author;
  double price;
  String imageUrl;
  String description;
  int quantity;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.quantity = 1,
  });

  String getDisplayPrice() {
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  // Metode untuk mendapatkan nilai harga numerik
  double getDisplayPriceValue() {
    return price;
  }

  void setQuantity(int newQuantity) {
    if (newQuantity >= 0) {
      quantity = newQuantity;
    }
  }
}