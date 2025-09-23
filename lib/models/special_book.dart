// lib/models/special_book.dart

import 'book.dart';

class PremiumBook extends Book {
  // Ubah dari `final double bonusPrice;` menjadi properti privat
  double _bonusPrice;

  PremiumBook({ // Hapus `const`
    required super.id,
    required super.title,
    required super.author,
    required super.price,
    required super.imageUrl,
    required super.description,
    required double bonusPrice,
  }) : _bonusPrice = bonusPrice;

  // Getter eksplisit untuk bonusPrice
  double get bonusPrice => _bonusPrice;

  // Setter eksplisit untuk bonusPrice
  set bonusPrice(double newBonusPrice) {
    if (newBonusPrice >= 0) {
      _bonusPrice = newBonusPrice;
    }
  }

  // Override metode getDisplayPrice dari kelas induk (Polymorphism)
  @override
  String getDisplayPrice() {
    return 'Rp ${(price + _bonusPrice).toStringAsFixed(0)} (Premium)';
  }
}

class SaleBook extends Book {
  int _discountPercentage;

  SaleBook({ // Hapus `const`
    required super.id,
    required super.title,
    required super.author,
    required super.price,
    required super.imageUrl,
    required super.description,
    required int discountPercentage,
  }) : _discountPercentage = discountPercentage;

  // Getter eksplisit untuk discountPercentage
  int get discountPercentage => _discountPercentage;

  // Setter eksplisit untuk discountPercentage
  set discountPercentage(int newDiscountPercentage) {
    if (newDiscountPercentage >= 0 && newDiscountPercentage <= 100) {
      _discountPercentage = newDiscountPercentage;
    }
  }

  // Override metode getDisplayPrice dari kelas induk (Polymorphism)
  @override
  String getDisplayPrice() {
    double discountedPrice = price * (1 - _discountPercentage / 100);
    return 'Rp ${discountedPrice.toStringAsFixed(0)} (Sale)';
  }
}