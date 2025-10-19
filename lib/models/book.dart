// lib/models/book.dart
import 'dart:math';

class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final String imageUrl;
  final String description;
  final String type;
  int quantity;

  final int? discountPercentage;

  final double? bonusPrice;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.type = 'regular',
    this.quantity = 1,
    this.discountPercentage,
    this.bonusPrice,
  }) {
    if (quantity < 1) quantity = 1;
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'regular',
      quantity: (json['quantity'] ?? 1) is int
          ? (json['quantity'] as int)
          : (json['quantity'] as num).toInt(),
      discountPercentage: (json['discountPercentage'] as num?)?.toInt(),
      bonusPrice: (json['bonusPrice'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'type': type,
      'quantity': quantity,
      'discountPercentage': discountPercentage,
      'bonusPrice': bonusPrice,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    double? price,
    String? imageUrl,
    String? description,
    int? quantity,
    int? discountPercentage,
    double? bonusPrice,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      quantity:
          (quantity ?? this.quantity) < 1 ? 1 : (quantity ?? this.quantity),
      discountPercentage: discountPercentage ?? this.discountPercentage,
      bonusPrice: bonusPrice ?? this.bonusPrice,
    );
  }

  void setQuantity(int newQuantity) {
    quantity = newQuantity < 1 ? 1 : newQuantity;
  }

  bool get isDiscounted =>
      discountPercentage != null && discountPercentage! > 0;

  double getDisplayPriceValue() {
    double finalPrice = price;
    if (isDiscounted) {
      finalPrice = price * (1 - (discountPercentage! / 100.0));
    } else if (type.toLowerCase() == 'premium' && bonusPrice != null) {
      finalPrice += bonusPrice!;
    }
    return (finalPrice / 100).round() * 100;
  }

  String getDisplayPrice() {
    double finalPrice = getDisplayPriceValue();
    return 'Rp ${finalPrice.toStringAsFixed(0)}';
  }

  String? getDisplayOriginalPrice() {
    if (isDiscounted) {
      return 'Rp ${price.toStringAsFixed(0)}';
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
