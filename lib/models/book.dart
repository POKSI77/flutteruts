// lib/models/book.dart

class Book {
  // Ubah properti dari final menjadi privat (dengan _)
  final String _id;
  String _title;
  String _author;
  double _price;
  String _imageUrl;
  String _description;
  int _quantity;

  Book({
    required String id,
    required String title,
    required String author,
    required double price,
    required String imageUrl,
    required String description,
    int quantity = 1,
  }) : _id = id,
       _title = title,
       _author = author,
       _price = price,
       _imageUrl = imageUrl,
       _description = description,
       _quantity = quantity;

  // Getter (untuk membaca data)
  String get id => _id;
  String get title => _title;
  String get author => _author;
  double get price => _price;
  String get imageUrl => _imageUrl;
  String get description => _description;
  int get quantity => _quantity;

  // Setter (untuk mengubah data secara terkontrol)
  set title(String newTitle) {
    if (newTitle.isNotEmpty) {
      _title = newTitle;
    }
  }

  set price(double newPrice) {
    if (newPrice > 0) {
      _price = newPrice;
    }
  }

  set quantity(int newQuantity) {
    if (newQuantity >= 0) {
      _quantity = newQuantity;
    }
  }

  // Metode untuk menunjukkan polimorfisme
  String getDisplayPrice() {
    return 'Rp ${_price.toStringAsFixed(0)}';
  }
}