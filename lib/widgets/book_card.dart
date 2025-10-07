// lib/widgets/book_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:favorite_button/favorite_button.dart';
import '../models/book.dart';
import '../models/cart_model.dart';
import '../models/favorite_model.dart'; // ✅ Perbaikan: Menggunakan FavoriteModel
import '../screens/book_detail_screen.dart';

class BookCard extends StatefulWidget {
  final Book book;
  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> with TickerProviderStateMixin {
  late AnimationController _animationControllerStar;
  late Animation<double> _scaleAnimationStar;
  late AnimationController _animationControllerCart;
  late Animation<double> _scaleAnimationCart;

  @override
  void initState() {
    super.initState();
    _animationControllerStar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimationStar = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationControllerStar, curve: Curves.easeOut),
    );

    _animationControllerCart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimationCart = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationControllerCart, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationControllerStar.dispose();
    _animationControllerCart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Perbaikan: Menggunakan FavoriteModel
    final favoriteModel = Provider.of<FavoriteModel>(context);
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final isFavorite = favoriteModel.isFavorite(widget.book);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: widget.book))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.network(widget.book.imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                  errorBuilder: (c,e,s)=> const Center(child: Icon(Icons.book, size: 50))),
              Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)], stops: const [0.5, 1.0]),
                )),
              ),
              Positioned(
                top: 8, right: 8,
                child: FavoriteButton(
                  isFavorite: isFavorite, // ✅ Menggunakan status dari FavoriteModel
                  iconSize: 30,
                  valueChanged: (fav) {
                    if (fav) {
                      favoriteModel.addFavorite(widget.book); // ✅ Memanggil metode yang benar
                      _animationControllerStar.forward().then((_) => _animationControllerStar.reverse());
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.book.title} added to favorites!')));
                    } else {
                      favoriteModel.removeFavorite(widget.book); // ✅ Memanggil metode yang benar
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.book.title} removed from favorites!')));
                    }
                  },
                ),
              ),
              // bottom info (title, author, price, cart)
              Positioned(
                bottom: 10, left: 10, right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.book.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(widget.book.author, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(widget.book.getDisplayPrice(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                          icon: ScaleTransition(scale: _scaleAnimationCart, child: const Icon(Icons.shopping_cart, color: Colors.blueAccent)),
                          onPressed: () {
                            cartModel.addItem(widget.book);
                            _animationControllerCart.forward().then((_) => _animationControllerCart.reverse());
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.book.title} added to cart!')));
                          },
                        ),
                      ),
                    ],),
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