import 'package:flutter/material.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/cart_model.dart';
import '../models/favorite_model.dart';
import '../screens/book_detail_screen.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';

class BookCard extends StatefulWidget {
  final Book book;
  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> with TickerProviderStateMixin {
  late AnimationController _animationControllerStar;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _animationControllerStar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Durasi tetap
    );
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lottieController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationControllerStar.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  void _onAddToCart() {
    Provider.of<CartModel>(context, listen: false).addItem(widget.book);

    if (!_lottieController.isAnimating) {
      _lottieController.forward(from: 0.0);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.book.title} added to cart!')),
    );
  }

  Widget _buildTypeLabel(Book book) {
    // ... (tidak berubah)
    Color color;
    String text;
    switch (book.type.toLowerCase()) {
      case 'premium':
        color = Colors.amber.shade700;
        text = 'Premium';
        break;
      case 'sale':
        color = Colors.redAccent;
        text = 'Sale';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDiscountLabel(int discountPercentage) {
    // ... (tidak berubah)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-$discountPercentage%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPriceDisplay() {
    // ... (tidak berubah)
    final book = widget.book;

    if (book.isDiscounted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            book.getDisplayOriginalPrice() ?? '',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.white70,
            ),
          ),
          Text(
            book.getDisplayPrice(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else {
      return Text(
        book.getDisplayPrice(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteModel = Provider.of<FavoriteModel>(context);
    final isFavorite = favoriteModel.isFavorite(widget.book);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(book: widget.book),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.network(
                widget.book.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (c, e, s) =>
                    const Center(child: Icon(Icons.book, size: 50)),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        // ignore: deprecated_member_use
                        Colors.black.withOpacity(0.7)
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: widget.book.isDiscounted
                    ? _buildDiscountLabel(widget.book.discountPercentage ?? 0)
                    : _buildTypeLabel(widget.book),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: FavoriteButton(
                  isFavorite: isFavorite,
                  iconSize: 30,
                  valueChanged: (fav) {
                    if (fav) {
                      favoriteModel.addFavorite(widget.book);
                      _animationControllerStar
                          .forward()
                          .then((_) => _animationControllerStar.reverse());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${widget.book.title} added to favorites!')),
                      );
                    } else {
                      favoriteModel.removeFavorite(widget.book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${widget.book.title} removed from favorites!')),
                      );
                    }
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Tetap gunakan ini
                  children: [
                    Text(
                      // Judul
                      widget.book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Jarak Judul -> Penulis
                    Text(
                      // Penulis
                      widget.book.author,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    // ✅ HAPUS SizedBox di sini
                    // const SizedBox(height: 4),

                    Row(
                      // Baris Harga & Cart
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ✅ UBAH: Coba gunakan center
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildPriceDisplay(), // Widget Harga
                        Stack(
                          // Tombol Cart
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                // Pengaturan compact dari sebelumnya
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                iconSize: 24,
                                icon: Icon(Icons.shopping_cart,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.blueAccent),
                                onPressed: _onAddToCart,
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _lottieController,
                              builder: (context, child) {
                                return _lottieController.isAnimating
                                    ? Lottie.asset(
                                        'assets/animations/cart_animation.json',
                                        width: 50,
                                        height: 50,
                                        controller: _lottieController,
                                        repeat: false,
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
