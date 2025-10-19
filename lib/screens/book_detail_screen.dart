import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/cart_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:favorite_button/favorite_button.dart';
import '../models/favorite_model.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  Widget _buildDiscountLabel(int discountPercentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(
        '-$discountPercentage%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTypeLabel(Book book) {
    Color color;
    String text;
    switch (book.type.toLowerCase()) {
      case 'premium':
        color = Colors.amber.shade700;
        text = 'Premium';
        break;
      case 'sale':
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPriceDisplay(BuildContext context) {
    final Color blueColor = Colors.blue[700]!;

    if (book.isDiscounted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.getDisplayOriginalPrice() ?? 'Rp 0',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.red.shade700,
                  decorationThickness: 2,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            book.getDisplayPrice(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: blueColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      );
    } else {
      return Text(
        book.getDisplayPrice(),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: blueColor,
              fontWeight: FontWeight.bold,
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            actions: [
              Consumer<FavoriteModel>(
                builder: (context, favoriteModel, child) {
                  final isFavorite = favoriteModel.isFavorite(book);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FavoriteButton(
                      isFavorite: isFavorite,
                      iconSize: 40,
                      iconColor: Colors.red,
                      valueChanged: (fav) {
                        if (fav) {
                          favoriteModel.addFavorite(book);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('${book.title} added to favorites!')),
                          );
                        } else {
                          favoriteModel.removeFavorite(book);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${book.title} removed from favorites!')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    book.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Center(
                      child: Icon(Icons.book, size: 100, color: Colors.grey),
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          // ignore: deprecated_member_use
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          // ignore: deprecated_member_use
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: SafeArea(
                      child: book.isDiscounted
                          ? _buildDiscountLabel(book.discountPercentage ?? 0)
                          : _buildTypeLabel(book),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      )
                          .animate()
                          .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
                      const SizedBox(height: 8),
                      Text(
                        'by ${book.author}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                      ),
                      const Divider(height: 32, thickness: 1),
                      _buildPriceDisplay(context),
                      const Divider(height: 32, thickness: 1),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            Provider.of<CartModel>(context, listen: false)
                                .addItem(book);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${book.title} added to cart!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
