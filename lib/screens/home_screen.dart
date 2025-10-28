import 'package:bookstore_app/main.dart';
import 'package:bookstore_app/screens/profile.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/book.dart';
import 'cart_screen.dart';
import '../models/cart_model.dart';
import '../models/favorite_model.dart';
import 'favorite_screen.dart';
import '../widgets/book_card.dart';

class HomeScreen extends StatefulWidget {
  final String? username;

  const HomeScreen({
    Key? key,
    this.username,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDark;
    final favoriteModel = Provider.of<FavoriteModel>(context);

    final List<Color> appBarGradientColors = [
      isDarkMode ? Colors.black : Colors.white,
      isDarkMode
          ? Colors.grey.shade900
          : const Color.fromARGB(255, 159, 200, 216),
    ];

    final Color appBarIconColor = isDarkMode ? Colors.white : Colors.black;
    final Color appBarTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color bodyBackgroundColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bodyBackgroundColor,
      appBar: AppBar(
        title: Text(
          'PokBook',
          style: TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.braahOne().fontFamily,
          ),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
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
// --- BARU: StreamBuilder untuk Cart Badge ---
          StreamBuilder<QuerySnapshot>(
            // 1. Dapatkan UID pengguna saat ini
            stream: (FirebaseAuth.instance.currentUser?.uid != null)
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('cart')
                    .snapshots()
                : null, // Stream null jika user logout
            builder: (context, snapshot) {
              int cartItemCount = 0; // Default 0

              // 2. Hitung jumlah item jika ada data
              if (snapshot.connectionState == ConnectionState.active &&
                  snapshot.hasData) {
                cartItemCount = snapshot.data!.docs.length;
              }

              // 3. Kembalikan IconButton dengan badge dinamis
              return IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.shopping_cart, color: appBarIconColor),
                    if (cartItemCount > 0) // Gunakan cartItemCount
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
                            '$cartItemCount', // Gunakan cartItemCount
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
          // --- AKHIR StreamBuilder Cart Badge ---
          IconButton(
            icon: const Icon(Icons.person),
            color: appBarIconColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      // --- INI ADALAH BAGIAN YANG DIUBAH ---
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: bodyBackgroundColor,
        child: Column( // 1. Body utama sekarang adalah Column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Welcome Message ada DI LUAR StreamBuilder
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _welcomeMessage ?? 'Loading...',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().slide(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
            ),
            
            // 3. Search Bar ada DI LUAR StreamBuilder
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v), // setState sekarang aman
                decoration: InputDecoration(
                  hintText: 'Cari judul atau penulis...',
                  prefixIcon: Icon(Icons.search,
                      color: isDarkMode ? Colors.white70 : Colors.black54),
                  hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: isDarkMode
                      // ignore: deprecated_member_use
                      ? Colors.white.withOpacity(0.1)
                      // ignore: deprecated_member_use
                      : Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),

            // 4. StreamBuilder sekarang HANYA untuk daftar buku
            Expanded( // Dibungkus Expanded agar mengisi sisa ruang
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('books').snapshots(),
                builder: (context, snapshot) {
                  
                  // --- Handle Status Loading ---
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDarkMode ? Colors.white : Colors.blueAccent,
                      ),
                    );
                  }

                  // --- Handle Status Error ---
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Terjadi error: ${snapshot.error}',
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black)));
                  }

                  // --- Handle Status Tidak Ada Data ---
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('Belum ada buku di database.',
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black)));
                  }

                  // --- 6. SUKSES! (Kode aman dari sebelumnya) ---
                  final List<Book> allBooks = snapshot.data!.docs.map((doc) {
                    final dynamic docData = doc.data();
                    if (docData == null || docData is! Map<String, dynamic>) {
                      return null;
                    }
                    Map<String, dynamic> data = docData;
                    data['id'] = doc.id;
                    return Book.fromJson(data);
                  }).whereType<Book>().toList();


                  // --- 7. Logika Filtering (Sudah benar) ---
                  final List<Book> filteredBooks;
                  if (_searchQuery.trim().isEmpty) {
                    filteredBooks = []; // Dikosongkan, karena akan tampil kategori
                  } else {
                    final q = _searchQuery.toLowerCase();
                    filteredBooks = allBooks.where((b) {
                      return b.title.toLowerCase().contains(q) ||
                          b.author.toLowerCase().contains(q);
                    }).toList();
                  }

                  final List<Book> regularBooks = allBooks
                      .where((b) => !b.isDiscounted && b.type.toLowerCase() != 'premium')
                      .toList();
                  final List<Book> premiumBooks = allBooks
                      .where((b) => !b.isDiscounted && b.type.toLowerCase() == 'premium')
                      .toList();
                  final List<Book> saleBooks =
                      allBooks.where((b) => b.isDiscounted).toList();


                  // --- 8. Kembalikan HANYA list yang bisa di-scroll ---
                  return ScrollConfiguration(
                    behavior: NoGlowBehavior(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // (Welcome message & Search bar sudah dipindah ke atas)

                          // Logika pencarian/tampilan buku
                          if (_searchQuery.trim().isNotEmpty)
                            if (filteredBooks.isEmpty)
                              _buildNotFoundWidget(context, isDarkMode)
                            else
                              _buildBookSection('Hasil Pencarian', filteredBooks,
                                  isDarkMode, favoriteModel)
                          else ...[
                            // Tampilkan kategori jika search bar kosong
                            _buildBookSection('Reguler', regularBooks, isDarkMode,
                                favoriteModel),
                            _buildBookSection('Premium', premiumBooks, isDarkMode,
                                favoriteModel),
                            _buildBookSection(
                                'Diskon', saleBooks, isDarkMode, favoriteModel),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  // FUNGSI HELPER HARUS ADA DI SINI:
  // (DI LUAR 'build', TAPI DI DALAM '_HomeScreenState')
  //
  Widget _buildBookSection(String title, List<Book> books, bool isDarkMode,
      FavoriteModel favoriteModel) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final isFavorite = favoriteModel.isFavorite(book);
              final dynamicKey = ValueKey('${book.id}_$isFavorite');

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 220,
                  child: BookCard(
                    key: dynamicKey,
                    book: book,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotFoundWidget(BuildContext context, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 100,
              color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Novel Tidak Ditemukan',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Kami tidak bisa menemukan judul atau penulis yang cocok dengan pencarian Anda. Silakan coba kata kunci lain.',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
