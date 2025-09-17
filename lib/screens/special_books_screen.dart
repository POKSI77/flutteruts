// lib/screens/special_books_screen.dart

import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/special_book.dart';
import 'book_detail_screen.dart';

class SpecialBooksScreen extends StatelessWidget {
  // Hapus kata kunci 'const' di sini
  SpecialBooksScreen({Key? key}) : super(key: key);

  final List<Book> specialBooks = [
    Book(
      id: '6',
      title: 'Seporsi Mie Ayam Sebelum Mati',
      author: 'Regular Author',
      price: 150000,
      imageUrl: 'https://image.gramedia.net/rs:fit:0:0/plain/https://cdn.gramedia.com/uploads/products/95ob5m98ur.jpg',
      description: 'This is a regular book with a normal price.',
    ),
    PremiumBook(
      id: '7',
      title: 'Advanced Flutter Programming',
      author: 'Dart Expert',
      price: 250000,
      bonusPrice: 50000,
      imageUrl: 'https://cdn.gramedia.com/uploads/items/book-2.jpg',
      description: 'A premium book with extra content.',
    ),
    SaleBook(
      id: '8',
      title: 'Flutter for Beginners',
      author: 'Flutter Fan',
      price: 100000,
      discountPercentage: 20,
      imageUrl: 'https://cdn.gramedia.com/uploads/items/book-3.jpg',
      description: 'A beginner\'s guide, now on sale!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Books'),
      ),
      body: ListView.builder(
        itemCount: specialBooks.length,
        itemBuilder: (context, index) {
          final book = specialBooks[index];
          return ListTile(
            leading: Image.network(book.imageUrl, width: 50, height: 75, fit: BoxFit.cover),
            title: Text(book.title),
            subtitle: Text(book.author),
            trailing: Text(book.getDisplayPrice(), style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(book: book),
                ),
              );
            },
          );
        },
      ),
    );
  }
}