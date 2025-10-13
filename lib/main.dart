import 'package:bookstore_app/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'models/cart_model.dart';
import 'models/special_book_model.dart';
import 'models/favorite_model.dart';
import 'screens/profile.screen.dart';
import 'firebase_options.dart';

// Theme notifier
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => SpecialBookModel()),
        ChangeNotifierProvider(create: (_) => FavoriteModel()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: const PokBookApp(),
    ),
  );
}

class PokBookApp extends StatelessWidget {
  const PokBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'PokBook',
          debugShowCheckedModeBanner: false,
          themeMode: theme.themeMode,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
          ),
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const HomeScreen(),
            '/profile': (context) => ProfileScreen(),
          },
        );
      },
    );
  }
}
