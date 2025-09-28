// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import 'cart_screen.dart';
import 'book_detail_screen.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';
import '../models/cart_model.dart';
import 'special_books_screen.dart';
import '../models/special_book.dart';
import '../models/special_book_model.dart';
import 'package:favorite_button/favorite_button.dart';



// Home Screen
class HomeScreen extends StatefulWidget {
  final String? username;

  const HomeScreen({
    Key? key,
    this.username,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  
  final List<Book> books = [
    Book(
      id: '1',
      title: 'Seporsi Mie Ayam Sebelum Mati',
      author: 'Brian Khrisna',
      price: 80000,
      imageUrl: 'https://image.gramedia.net/rs:fit:0:0/plain/https://cdn.gramedia.com/uploads/products/95ob5m98ur.jpg',
      description: 'Kumpulan cerita pendek yang merenungkan tentang hidup, kematian, dan makna di balik momen-momen kecil yang tak terduga. Sebuah renungan manis pahit yang mengajak Anda menemukan keindahan dalam kesederhanaan.',
    ),
    PremiumBook(
      id: '2',
      title: '3726',
      author: 'A. Fuadi',
      price: 5000,
      bonusPrice: 5,
      imageUrl: 'https://cdn.gramedia.com/uploads/products/9397p4603v.jpg',
      description: 'Di masa depan, sebuah sistem mengatur seluruh aspek kehidupan, bahkan nasib seseorang ditentukan oleh angka. Seorang pemuda berjuang melawan takdirnya, mempertanyakan kebebasan sejati, dan berani untuk hidup di luar kehendak sistem.',
    ),
    Book(
      id: '3',
      title: 'Gerbang Dialog Danur',
      author: 'Risa Saraswati',
      price: 78000,
      imageUrl: 'https://static.mizanstore.com/d/img/book/cover/covBK001247.jpg',
      description: 'Berdasarkan kisah nyata, novel horor ini mengisahkan Risa Saraswati, seorang indigo yang bisa melihat dan berinteraksi dengan hantu-hantu anak Belanda. Ikuti perjalanannya saat ia mencoba memahami dunia para arwah yang berada di balik gerbang dialognya.',
    ),
    SaleBook(
      id: '4',
      title: 'Dilan: Dia Adalah Dilanku Tahun 1990',
      author: 'Pidi Baiq',
      price: 80000,
      discountPercentage: 20,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/id/1/19/Dilan_1990_%28poster%29.jpg',
      description: 'Sebuah kisah romansa masa remaja yang berlatar belakang Kota Bandung tahun 1990. Saat Milea pindah ke sekolah baru, ia bertemu Dilan, seorang panglima geng motor yang cerdas dan unik. Novel ini akan membawa Anda kembali ke manisnya cinta pertama dan kenangan masa sekolah.',
    ),
    Book(
      id: '5',
      title: 'The Catcher in the Rye',
      author: 'J.D. Salinger',
      price: 87000,
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1398034300i/5107.jpg',
      description:'Ikuti petualangan Holden Caulfield, seorang remaja yang sinis dan pemberontak, dalam perjalanannya melintasi New York City. Sebuah kisah klasik tentang pencarian jati diri, melawan kemunafikan, dan memahami arti kedewasaan.',
    ),
  ];
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) {
      return "Selamat pagi";
    } else if (hour >= 12 && hour < 15) {
      return "Selamat siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat sore";
    } else {
      return "Selamat malam";
    }
  }

  String? _welcomeMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final username = widget.username ?? await _authService.getCurrentUser();
    final greeting = _getGreeting();
    setState(() {
      _welcomeMessage = '$greeting, ${username ?? "User"}!';
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await _authService.logout();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookstore'),
        actions: [
          Consumer<SpecialBookModel>(
            builder: (context, specialBookModel, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    if (specialBookModel.items.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${specialBookModel.items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SpecialBooksScreen(),
                    ),
                  );
                },
              );
            },
          ),
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cart.items.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Text(
              _welcomeMessage ?? 'Loading...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.6,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return BookCard(book: books[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
      CurvedAnimation(
        parent: _animationControllerStar,
        curve: Curves.easeOut,
      ),
    );

    _animationControllerCart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimationCart = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationControllerCart,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationControllerStar.dispose();
    _animationControllerCart.dispose();
    super.dispose();
  }

  void _toggleSpecial(Book book, SpecialBookModel specialBookModel) {
    if (specialBookModel.items.contains(book)) {
      specialBookModel.removeItem(book);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${book.title} removed from special books!'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      specialBookModel.addItem(book);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${book.title} added to special books!'),
          duration: const Duration(seconds: 1),
        ),
      );
      _animationControllerStar.forward().then((_) => _animationControllerStar.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: widget.book),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.network(
                widget.book.imageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.book, size: 50));
                },
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      // ignore: deprecated_member_use
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
Positioned(
  top: 8,
  right: 8,
  child: Consumer<SpecialBookModel>(
    builder: (context, specialBookModel, child) {
      bool isSpecial = specialBookModel.items.contains(widget.book);
      return FavoriteButton(
        isFavorite: isSpecial, // kondisi awal
        iconSize: 40, // biar lebih jelas, bisa disesuaikan
        valueChanged: (_isFavorite) {
          if (_isFavorite) {
            specialBookModel.addItem(widget.book);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.book.title} added to special books!'),
                duration: const Duration(seconds: 1),
              ),
            );
          } else {
            specialBookModel.removeItem(widget.book);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.book.title} removed from special books!'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
      );
    },
  ),
),

              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.book.author,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.book.getDisplayPrice(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: ScaleTransition(
                              scale: _scaleAnimationCart,
                              child: const Icon(Icons.shopping_cart, color: Colors.blueAccent),
                            ),
                            onPressed: () {
                              Provider.of<CartModel>(context, listen: false).addItem(widget.book);
                              _animationControllerCart.forward().then((_) => _animationControllerCart.reverse());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.book.title} added to cart!'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
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