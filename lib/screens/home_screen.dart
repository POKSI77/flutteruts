import 'package:bookstore_app/main.dart';
import 'package:bookstore_app/screens/profile.screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  final List<Book> books = [
    Book(
      id: '1',
      title: 'Seporsi Mie Ayam Sebelum Mati',
      author: 'Brian Khrisna',
      price: 80000,
      imageUrl:
          'https://images.weserv.nl/?url=image.gramedia.net/rs:fit:0:0/plain/https://cdn.gramedia.com/uploads/products/95ob5m98ur.jpg',
      description:
          'Kumpulan cerita pendek yang merenungkan tentang hidup, kematian, dan makna di balik momen-momen kecil yang tak terduga. Penulis mengajak kita menyelami pemikiran tokoh-tokohnya saat menghadapi titik krusial dalam hidup, seringkali dengan sentuhan melankolis namun penuh harapan, seperti kehangatan semangkuk mie ayam.',
    ),
    Book(
      id: '2',
      title: '3726',
      author: 'A. Fuadi',
      price: 50000,
      imageUrl:
          'https://images.weserv.nl/?url=cdn.gramedia.com/uploads/products/9397p4603v.jpg',
      description:
          'Dalam dunia masa depan yang diatur oleh sistem angka absolut, nasib setiap individu telah ditentukan. Seorang pemuda dengan nomor 3726 menolak takdirnya dan memulai perjuangan berbahaya untuk mencari arti kebebasan sejati, menentang sistem yang mengontrol segalanya.',
      type: 'premium',
      bonusPrice: 5000,
    ),
    Book(
      id: '3',
      title: 'Gerbang Dialog Danur',
      author: 'Risa Saraswati',
      price: 78000,
      imageUrl:
          'https://images.weserv.nl/?url=static.mizanstore.com/d/img/book/cover/covBK001247.jpg',
      description:
          'Berdasarkan pengalaman nyata penulis sebagai seorang indigo, buku ini membuka pintu ke dunia lain. Risa berbagi kisahnya berkomunikasi dengan teman-teman gaibnya—lima hantu anak Belanda—mengungkap tragedi masa lalu mereka dan ikatan unik yang terjalin.',
    ),
    Book(
      id: '4',
      title: 'Nineteen Eighty-Four (1984)',
      author: 'George Orwell',
      price: 110000,
      imageUrl:
          'https://images.weserv.nl/?url=cdn.gramedia.com/uploads/products/8n-45t7t60.jpg',
      description:
          'Sebuah novel distopia klasik yang mengerikan tentang dunia totaliter Oceania, di mana Partai mengontrol setiap aspek kehidupan di bawah pengawasan Big Brother. Winston Smith memulai pemberontakan pribadi yang berbahaya terhadap rezim yang menindas pikiran dan kebenaran.',
      discountPercentage: 15,
    ),
    Book(
      id: '5',
      title: 'The Catcher in the Rye',
      author: 'J.D. Salinger',
      price: 87000,
      imageUrl:
          'https://images.weserv.nl/npr.brightspotcdn.com/dims4/default/48e622e/2147483647/strip/true/crop/363x574+0+0/resize/1760x2784!/format/webp/quality/90/?url=http%3A%2F%2Fnpr-brightspot.s3.amazonaws.com%2Flegacy%2Fsites%2Fwkar%2Ffiles%2Fcatcher_in_the_rye_cover.png',
      description:
          'Novel klasik Amerika tentang kegelisahan remaja melalui sudut pandang Holden Caulfield yang sinis dan pemberontak. Setelah dikeluarkan dari sekolah, ia menghabiskan beberapa hari di New York, merenungkan kepalsuan dunia dewasa, kehilangan, dan pencarian makna hidup.',
    ),
    Book(
      id: '6',
      title: 'Bumi Manusia',
      author: 'Pramoedya Ananta Toer',
      price: 95000,
      imageUrl:
          'https://images.weserv.nl/?url=https://upload.wikimedia.org/wikipedia/id/thumb/5/51/Bumi_Manusia_poster.jpg/500px-Bumi_Manusia_poster.jpg',
      description:
          'Bagian pertama dari Tetralogi Buru yang legendaris, berlatar Hindia Belanda awal abad ke-20. Mengisahkan Minke, seorang priyayi Jawa terpelajar, yang jatuh cinta pada Annelies Mellema, seorang Indo-Belanda, dan harus menghadapi konflik rasial, sosial, dan politik era kolonial.',
    ),
    Book(
      id: '7',
      title: 'Laskar Pelangi',
      author: 'Andrea Hirata',
      price: 70000,
      imageUrl:
          'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/id/8/8e/Laskar_pelangi_sampul.jpg',
      description:
          'Kisah inspiratif tentang sepuluh anak dari keluarga miskin di Pulau Belitong yang bersekolah di SD Muhammadiyah Gantong yang hampir rubuh. Dipimpin oleh Ikal dan Lintang yang jenius, mereka berjuang meraih mimpi melalui pendidikan dengan semangat persahabatan yang kuat.',
    ),
    Book(
      id: '8',
      title: 'The Hobbit',
      author: 'J.R.R. Tolkien',
      price: 135000,
      imageUrl:
          'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/4/4a/TheHobbit_FirstEdition.jpg/220px-TheHobbit_FirstEdition.jpg',
      description:
          'Petualangan epik Bilbo Baggins, seorang hobbit yang mencintai kenyamanan rumahnya, saat ia secara tak terduga direkrut oleh penyihir Gandalf dan tiga belas kurcaci untuk melakukan perjalanan berbahaya merebut kembali harta karun yang dicuri oleh naga Smaug di Lonely Mountain.',
    ),
    Book(
      id: '9',
      title: 'Negeri 5 Menara',
      author: 'Ahmad Fuadi',
      price: 75000,
      imageUrl:
          'https://images.weserv.nl/?url=s3-ap-southeast-1.amazonaws.com/ebook-previews/1682/10530/1.jpg',
      description:
          'Terinspirasi dari kisah nyata, novel ini mengikuti perjalanan Alif Fikri dari Minangkabau ke Pondok Madani Gontor di Jawa Timur. Bersama lima sahabatnya, ia belajar tentang disiplin, persahabatan, impian, dan kekuatan mantra "Man Jadda Wajada" (Siapa yang bersungguh-sungguh akan berhasil).',
    ),
    Book(
      id: '10',
      title: 'Supernova: KPBJ',
      author: 'Dee Lestari',
      price: 110000,
      imageUrl:
          'https://images.weserv.nl/?url=static.mizanstore.com/d/img/book/cover/covBT-533.jpg',
      description:
          'Buku pertama dari seri fiksi ilmiah-filosofis Supernova. Dua pasangan gay, Reuben dan Dimas, menciptakan cerita fiksi tentang Ksatria, Puteri, dan Bintang Jatuh yang ternyata memiliki keterkaitan misterius dengan tokoh nyata bernama Ferre, Rana, dan Diva.',
      type: 'premium',
      bonusPrice: 7500,
    ),
    Book(
      id: '11',
      title: 'The Da Vinci Code',
      author: 'Dan Brown',
      price: 150000,
      imageUrl:
          'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/6/6b/DaVinciCode.jpg/220px-DaVinciCode.jpg',
      description:
          'Sebuah thriller misteri yang mendebarkan. Simbolog Harvard, Robert Langdon, terlibat dalam penyelidikan pembunuhan di Louvre yang membawanya mengungkap konspirasi kuno terkait Holy Grail, tersembunyi dalam karya seni Leonardo da Vinci dan sejarah rahasia Kekristenan.',
      discountPercentage: 20,
    ),
    Book(
      id: '12',
      title: 'Cantik Itu Luka',
      author: 'Eka Kurniawan',
      price: 88000,
      imageUrl:
          'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/id/d/d2/CiL_%28sampul%29.jpg',
      description:
          'Sebuah novel epik yang memadukan sejarah Indonesia dari era kolonial hingga Orde Baru dengan unsur realisme magis, kekerasan, dan humor gelap. Mengisahkan kehidupan tragis Dewi Ayu dan keempat putrinya di kota fiksi Halimunda.',
      discountPercentage: 10,
    ),
    Book(
      id: '13',
      title: 'Harry Potter and the Sorcerer\'s Stone',
      author: 'J.K. Rowling',
      price: 150000,
      imageUrl:
          'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/6/6b/Harry_Potter_and_the_Philosopher%27s_Stone_Book_Cover.jpg/220px-Harry_Potter_and_the_Philosopher%27s_Stone_Book_Cover.jpg',
      description:
          'Buku pertama yang memperkenalkan dunia sihir Harry Potter. Harry, seorang yatim piatu yang tinggal bersama paman dan bibinya yang kejam, mengetahui di ulang tahunnya yang kesebelas bahwa ia adalah seorang penyihir dan diundang ke Sekolah Sihir Hogwarts.',
      type: 'premium',
      bonusPrice: 7500,
    ),
    Book(
      id: '14',
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      price: 120000,
      imageUrl:
          'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/4/4f/To_Kill_a_Mockingbird_%28first_edition_cover%29.jpg/220px-To_Kill_a_Mockingbird_%28first_edition_cover%29.jpg',
      description:
          'Novel klasik Amerika pemenang Pulitzer Prize, berlatar Depresi Besar di Alabama. Diceritakan melalui mata Scout Finch, novel ini mengeksplorasi tema rasisme, prasangka, dan moralitas saat ayahnya, pengacara Atticus Finch, membela Tom Robinson, seorang pria kulit hitam yang dituduh secara salah.',
    ),
    Book(
      id: '15',
      title: 'The Little Prince',
      author: 'Antoine de Saint-Exupéry',
      price: 90000,
      imageUrl:
          'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/en/thumb/0/05/Littleprince.JPG/220px-Littleprince.JPG',
      description:
          'Kisah puitis dan filosofis tentang seorang pilot yang pesawatnya jatuh di Gurun Sahara dan bertemu dengan seorang anak laki-laki misterius, Pangeran Kecil, yang berasal dari asteroid kecil. Melalui percakapan mereka, buku ini membahas tema kesepian, persahabatan, cinta, kehilangan, dan makna hidup.',
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

  List<Book> get _regularBooks => books
      .where((b) => !b.isDiscounted && b.type.toLowerCase() != 'premium')
      .toList();
  List<Book> get _premiumBooks => books
      .where((b) => !b.isDiscounted && b.type.toLowerCase() == 'premium')
      .toList();
  List<Book> get _saleBooks => books.where((b) => b.isDiscounted).toList();

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
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: bodyBackgroundColor,
        child: ScrollConfiguration(
          behavior: NoGlowBehavior(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
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
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),

                // Logika pencarian/tampilan buku
                if (_searchQuery.trim().isNotEmpty)
                  if (_filteredBooks.isEmpty)
                    _buildNotFoundWidget(context, isDarkMode)
                  else
                    _buildBookSection('Hasil Pencarian', _filteredBooks,
                        isDarkMode, favoriteModel)
                else ...[
                  _buildBookSection(
                      'Reguler', _regularBooks, isDarkMode, favoriteModel),
                  _buildBookSection(
                      'Premium', _premiumBooks, isDarkMode, favoriteModel),
                  _buildBookSection(
                      'Diskon', _saleBooks, isDarkMode, favoriteModel),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

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

// HELPER CLASS
class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
