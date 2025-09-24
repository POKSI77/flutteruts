// lib/models/special_book.dart

import 'book.dart';

class PremiumBook extends Book {
  double _bonusPrice;

  PremiumBook({
    required super.id,
    required super.title,
    required super.author,
    required super.price,
    required super.imageUrl,
    required super.description,
    required double bonusPrice,
  }) : _bonusPrice = bonusPrice, super(quantity: 1);

  double get bonusPrice => _bonusPrice;

  set bonusPrice(double newBonusPrice) {
    if (newBonusPrice >= 0) {
      _bonusPrice = newBonusPrice;
    }
  }

  @override
  String getDisplayPrice() {
    return 'Rp ${(price + _bonusPrice).toStringAsFixed(0)} (Premium)';
  }

  // Tambahkan override ini
  @override
  double getDisplayPriceValue() {
    return price + _bonusPrice;
  }
}

class SaleBook extends Book {
  int _discountPercentage;

  SaleBook({
    required super.id,
    required super.title,
    required super.author,
    required super.price,
    required super.imageUrl,
    required super.description,
    required int discountPercentage,
  }) : _discountPercentage = discountPercentage, super(quantity: 1);

  int get discountPercentage => _discountPercentage;

  set discountPercentage(int newDiscountPercentage) {
    if (newDiscountPercentage >= 0 && newDiscountPercentage <= 100) {
      _discountPercentage = newDiscountPercentage;
    }
  }

  @override
  String getDisplayPrice() {
    double discountedPrice = price * (1 - _discountPercentage / 100);
    return 'Rp ${discountedPrice.toStringAsFixed(0)} (Sale)';
  }

  @override
  double getDisplayPriceValue() {
    return price * (1 - _discountPercentage / 100);
  }
}