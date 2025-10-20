// lib/screens/favorite_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite_model.dart';
import '../models/book.dart'; // Import Book model
import '../widgets/book_card.dart'; // Import BookCard widget
import '../main.dart'; // Import ThemeNotifier
import 'book_detail_screen.dart'; // Import BookDetailScreen (meskipun BookCard sudah handle onTap)

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ambil data favorit dan status tema
    final favoriteModel = Provider.of<FavoriteModel>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDark;

    // Definisikan warna berdasarkan mode (copy dari HomeScreen)
    final List<Color> appBarGradientColors = [
      isDarkMode ? Colors.black : Colors.white,
      isDarkMode ? Colors.grey.shade900 : const Color.fromARGB(255, 159, 200, 216),
    ];
    final Color appBarTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color appBarIconColor = isDarkMode ? Colors.white : Colors.black;
    final Color bodyBackgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.grey.shade100; // Warna dasar gelap/terang
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subtleTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bodyBackgroundColor, // Terapkan background body
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(
            color: appBarTextColor, // Terapkan warna teks AppBar
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // Terapkan gradien dan warna ikon
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: appBarIconColor), // Warna ikon back
        elevation: 4,
      ),
      body: favoriteModel.favorites.isEmpty
          ? Center( // Tampilan jika kosong
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: subtleTextColor),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite books yet',
                    style: TextStyle(fontSize: 18, color: subtleTextColor),
                  ),
                ],
              ),
            )
          : GridView.builder( // Gunakan GridView seperti di screenshot
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,         // 2 kolom
                childAspectRatio: 2 / 3,   // Rasio card (sesuaikan jika perlu)
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: favoriteModel.favorites.length,
              itemBuilder: (ctx, index) {
                final book = favoriteModel.favorites[index];
                // Gunakan BookCard. Logika add/remove favorit sudah ada di dalamnya
                // dan akan update state di HomeScreen juga.
                return BookCard(book: book);
              },
            ),
    );
  }
}