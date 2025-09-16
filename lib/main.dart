import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final loggedIn = await authService.isLoggedIn();
  final currentUser = await authService.getCurrentUser();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => authService,
        ),
      ],
      child: MyApp(
        isLoggedIn: loggedIn,
        currentUser: currentUser,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? currentUser;

  const MyApp({
    Key? key,
    required this.isLoggedIn,
    this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookstore App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // tentukan halaman awal berdasarkan session
      home: isLoggedIn
          ? HomeScreen(username: currentUser)
          : const AuthScreen(),
    );
  }
}
