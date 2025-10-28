import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookstore_app/main.dart';
import 'package:bookstore_app/models/cart_model.dart';
import 'package:bookstore_app/models/favorite_model.dart';
import 'package:bookstore_app/screens/cart_screen.dart';
import 'package:bookstore_app/screens/favorite_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _email = prefs.getString('email') ?? 'No email';
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDark;

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
          'Profile',
          style: TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.braahOne().fontFamily,
          ),
        ),
        iconTheme: IconThemeData(color: appBarTextColor),
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
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: bodyBackgroundColor,
        child: ScrollConfiguration(
          behavior: NoGlowBehavior(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade900
                        : const Color.fromARGB(255, 159, 200, 216)
                            // ignore: deprecated_member_use
                            .withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : const Color.fromARGB(255, 159, 200, 216)
                                  // ignore: deprecated_member_use
                                  .withOpacity(0.5),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: isDarkMode
                              ? Colors.white70
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _username ?? 'Loading...',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _email ?? 'Loading...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_outline,
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                        title: Text('Edit Profile',
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black)),
                        trailing: Icon(Icons.chevron_right,
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                        onTap: () {},
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.settings_outlined,
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                        title: Text('Settings',
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black)),
                        trailing: Icon(Icons.chevron_right,
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                        onTap: () {},
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.help_outline,
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                        title: Text('Help & Support',
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black)),
                        trailing: Icon(Icons.chevron_right,
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                        onTap: () {},
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
