// lib/models/book.dart

import 'package:intl/intl.dart';

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
   
    final formatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ',  
      decimalDigits: 0, 
    );
    return formatter.format(price);
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