// lib/screens/book_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/cart_model.dart';
import '../models/favorite_model.dart'; // ✅ Menambahkan import untuk FavoriteModel

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  // ✅ Menghapus variabel _isFavorite karena kita akan menggunakan Provider

  @override
  Widget build(BuildContext context) {
    // ✅ Mengakses FavoriteModel
    final favoriteModel = Provider.of<FavoriteModel>(context);
    final isFavorite = favoriteModel.isFavorite(widget.book);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
          // Tombol favorit dengan ikon yang bisa berubah
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border, // ✅ Menggunakan status dari model
              color: isFavorite ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              // ✅ Mengubah status favorit menggunakan metode dari model
              if (isFavorite) {
                favoriteModel.removeFavorite(widget.book);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.book.title} removed from favorites!'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              } else {
                favoriteModel.addFavorite(widget.book);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.book.title} added to favorites!'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.book.imageUrl.isNotEmpty
                ? Image.network(
                    widget.book.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 300,
                        child: Center(
                          child: Icon(Icons.book, size: 50),
                        ),
                      );
                    },
                  )
                : const SizedBox(
                    height: 300,
                    child: Center(
                      child: Icon(Icons.book, size: 50),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${widget.book.author.isNotEmpty ? widget.book.author : 'Unknown Author'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.book.getDisplayPrice(),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.book.description.isNotEmpty
                        ? widget.book.description
                        : 'No description available.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<CartModel>(
        builder: (context, cart, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                cart.addItem(widget.book);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Book added to cart'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Add to Cart'),
            ),
          );
        },
      ),
    );
  }
}