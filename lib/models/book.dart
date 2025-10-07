// lib/models/book.dart

class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final String imageUrl;
  final String description;
  int quantity;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.quantity = 1,
  }) {
    // Validasi quantity minimal 1
    if (quantity < 1) quantity = 1;
  }

  /// Factory constructor untuk parsing dari JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] ?? 1) is int
          ? (json['quantity'] as int)
          : (json['quantity'] as num).toInt(),
    );
  }

  /// Optional: static compatibility method (jika ada file lama yang pakai)
  static Book fromJsonStatic(Map<String, dynamic> json) => Book.fromJson(json);

  /// Convert Book ke JSON (untuk SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'quantity': quantity,
    };
  }

  /// Copy method (buat update sebagian field tanpa bikin baru manual)
  Book copyWith({
    String? id,
    String? title,
    String? author,
    double? price,
    String? imageUrl,
    String? description,
    int? quantity,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      quantity: (quantity ?? this.quantity) < 1 ? 1 : (quantity ?? this.quantity),
    );
  }

  /// Setter quantity (dipakai CartModel)
  void setQuantity(int newQuantity) {
    quantity = newQuantity < 1 ? 1 : newQuantity;
  }

  /// Untuk menampilkan harga sebagai String (dipanggil di UI)
  String getDisplayPrice() {
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  /// Untuk perhitungan numerik (total harga)
  double getDisplayPriceValue() {
    return price;
  }

  /// Override equals & hashCode supaya Book bisa dibandingkan dengan id
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}