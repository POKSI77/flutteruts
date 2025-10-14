// lib/screens/home_screen.dart

import 'package:bookstore_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';
import 'cart_screen.dart';
import 'book_detail_screen.dart';
import '../services/auth_service.dart';
import '../models/cart_model.dart';
import '../models/special_book.dart';
import '../models/favorite_model.dart';
import 'package:favorite_button/favorite_button.dart';
import 'favorite_screen.dart';
import 'package:lottie/lottie.dart';

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
      imageUrl:
          'https://images.weserv.nl/?url=image.gramedia.net/rs:fit:0:0/plain/https://cdn.gramedia.com/uploads/products/95ob5m98ur.jpg',
      description:
          'Kumpulan cerita pendek yang merenungkan tentang hidup, kematian, dan makna di balik momen-momen kecil yang tak terduga. Sebuah renungan manis pahit yang mengajak Anda menemukan keindahan dalam kesederhanaan.',
    ),
    PremiumBook(
      id: '2',
      title: '3726',
      author: 'A. Fuadi',
      price: 50000,
      bonusPrice: 5,
      imageUrl: 'https://images.weserv.nl/?url=cdn.gramedia.com/uploads/products/9397p4603v.jpg',
      description:
          'Di masa depan, sebuah sistem mengatur seluruh aspek kehidupan, bahkan nasib seseorang ditentukan oleh angka. Seorang pemuda berjuang melawan takdirnya, mempertanyakan kebebasan sejati, dan berani untuk hidup di luar kehendak sistem.',
    ),
    Book(
      id: '3',
      title: 'Gerbang Dialog Danur',
      author: 'Risa Saraswati',
      price: 78000,
      imageUrl:
          'https://images.weserv.nl/?url=static.mizanstore.com/d/img/book/cover/covBK001247.jpg',
      description:
          'Berdasarkan kisah nyata, novel horor ini mengisahkan Risa Saraswati, seorang indigo yang bisa melihat dan berinteraksi dengan hantu-hantu anak Belanda. Ikuti perjalanannya saat ia mencoba memahami dunia para arwah yang berada di balik gerbang dialognya.',
    ),
    SaleBook(
      id: '4',
      title: 'Dilan: Dia Adalah Dilanku Tahun 1990',
      author: 'Pidi Baiq',
      price: 80000,
      discountPercentage: 20,
      imageUrl:
          'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/id/1/19/Dilan_1990_%28poster%29.jpg',
      description:
          'Sebuah kisah romansa masa remaja yang berlatar belakang Kota Bandung tahun 1990. Saat Milea pindah ke sekolah baru, ia bertemu Dilan, seorang panglima geng motor yang cerdas dan unik. Novel ini akan membawa Anda kembali ke manisnya cinta pertama dan kenangan masa sekolah.',
    ),
    Book(
      id: '5',
      title: 'The Catcher in the Rye',
      author: 'J.D. Salinger',
      price: 87000,
      imageUrl:
          'https://images.weserv.nl/npr.brightspotcdn.com/dims4/default/48e622e/2147483647/strip/true/crop/363x574+0+0/resize/1760x2784!/format/webp/quality/90/?url=http%3A%2F%2Fnpr-brightspot.s3.amazonaws.com%2Flegacy%2Fsites%2Fwkar%2Ffiles%2Fcatcher_in_the_rye_cover.png',
      description:
          'Ikuti petualangan Holden Caulfield, seorang remaja yang sinis dan pemberontak, dalam perjalanannya melintasi New York City. Sebuah kisah klasik tentang pencarian jati diri, melawan kemunafikan, dan memahami arti kedewasaan.',
    ),
  ];

  String _searchQuery = '';

  List<Book> get _filteredBooks {
    if (_searchQuery.trim().isEmpty) return books;
    final q = _searchQuery.toLowerCase();
    return books.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q);
    }).toList();
  }

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
    final prefs = await SharedPreferences.getInstance();
    final username = widget.username ?? prefs.getString('username') ?? 'User';
    setState(() {
      _welcomeMessage = '${_getGreeting()}, $username!';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDark;

    // Gradien untuk AppBar, warnanya akan berubah tergantung tema
    final List<Color> appBarGradientColors = [
      isDarkMode ? Colors.black : Colors.white,
      isDarkMode ? Colors.grey.shade900 : const Color(0xFFBBDEFB),
    ];

    // Warna ikon dan teks di AppBar: menyesuaikan tema
    final Color appBarIconColor = isDarkMode ? Colors.white : Colors.black;
    final Color appBarTextColor = isDarkMode ? Colors.white : Colors.black;

    // Warna latar belakang body: putih untuk terang, abu-abu gelap untuk gelap
    final Color bodyBackgroundColor =
        isDarkMode ? Colors.black87 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookstore',
          style: TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors, // ✅ Gradien yang dinamis
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: appBarIconColor,
            ),
            tooltip:
                isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              themeNotifier.toggle();
            },
          ),
          Consumer<FavoriteModel>(
            builder: (context, favoriteModel, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.favorite,
                        color: isDarkMode ? Colors.red.shade200 : Colors.red),
                    if (favoriteModel.favorites.isNotEmpty)
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
                            '${favoriteModel.favorites.length}',
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
                      builder: (context) => const FavoriteScreen(),
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
                    Icon(Icons.shopping_cart, color: appBarIconColor),
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
            icon: Icon(Icons.person, color: appBarIconColor),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: bodyBackgroundColor, // ✅ Mengubah warna background body
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _welcomeMessage ?? 'Loading...',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: isDarkMode
                          ? Colors.white
                          : Colors.black, // ✅ Sesuaikan warna teks
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().slide(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari judul atau penulis...',
                  prefixIcon: Icon(Icons.search,
                      color: isDarkMode
                          ? Colors.white70
                          : Colors.black54), // ✅ Warna ikon pencarian
                  hintStyle: TextStyle(
                      color: isDarkMode
                          ? Colors.white70
                          : Colors.black54), // ✅ Warna hint
                  filled: true,
                  // ignore: deprecated_member_use
                  fillColor: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey
                          .withOpacity(0.1), // ✅ Latar belakang search bar
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black), // ✅ Warna teks input
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
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  return BookCard(book: _filteredBooks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Full BookCard with favorite + cart + animations
class BookCard extends StatefulWidget {
  final Book book;

  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> with TickerProviderStateMixin {
  late AnimationController _animationControllerStar;
  late AnimationController _lottieController;
  bool _isLottieVisible = false;

  @override
  void initState() {
    super.initState();
    _animationControllerStar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Duration adjusted
    );
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isLottieVisible = false; // Hide Lottie after it's done
        });
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

    // Show Lottie and start animation
    setState(() {
      _isLottieVisible = true;
    });
    _lottieController.forward(from: 0.0);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.book.title} added to cart!')));
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
                builder: (_) => BookDetailScreen(book: widget.book))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.network(widget.book.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (c, e, s) =>
                      const Center(child: Icon(Icons.book, size: 50))),
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
                      stops: const [
                        0.5,
                        1.0
                      ]),
                )),
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '${widget.book.title} added to special books!')));
                    } else {
                      favoriteModel.removeFavorite(widget.book);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '${widget.book.title} removed from special books!')));
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
                  children: [
                    Text(widget.book.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(widget.book.author,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.book.getDisplayPrice(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Stack(
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
                                return _isLottieVisible
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
