import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/special_book_model.dart';
import 'book_detail_screen.dart'; 

class SpecialBooksScreen extends StatelessWidget {
  const SpecialBooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Books'),
      ),
      body: Consumer<SpecialBookModel>(
        builder: (context, specialBookModel, child) {
          if (specialBookModel.items.isEmpty) {
            return const Center(
              child: Text(
                'No special books yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: specialBookModel.items.length,
            itemBuilder: (context, index) {
              final book = specialBookModel.items[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                child: ListTile(
                  leading: book.imageUrl.isNotEmpty
                      ? Image.network(
                          book.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.book, size: 40);
                          },
                        )
                      : const Icon(Icons.book, size: 40),
                  title: Text(
                    book.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(book.getDisplayPrice()), // Menggunakan getDisplayPrice
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      specialBookModel.removeItem(book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${book.title} removed from special books.'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    // Navigasi ke detail buku saat list item diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(book: book),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}