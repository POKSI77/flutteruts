import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite_model.dart';
import '../widgets/book_card.dart';
import '../main.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteModel = Provider.of<FavoriteModel>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDark;
    final List<Color> appBarGradientColors = [
      isDarkMode ? Colors.black : Colors.white,
      isDarkMode
          ? Colors.grey.shade900
          : const Color.fromARGB(255, 159, 200, 216),
    ];
    final Color appBarTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color appBarIconColor = isDarkMode ? Colors.white : Colors.black;
    final Color bodyBackgroundColor =
        isDarkMode ? const Color(0xFF121212) : Colors.grey.shade100;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subtleTextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bodyBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: appBarIconColor),
        elevation: 4,
      ),
      body: favoriteModel.favorites.isEmpty
          ? Center(
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
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: favoriteModel.favorites.length,
              itemBuilder: (ctx, index) {
                final book = favoriteModel.favorites[index];
                return BookCard(book: book);
              },
            ),
    );
  }
}
