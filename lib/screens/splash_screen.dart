import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Beri jeda 2 detik sebelum navigasi
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await _authService.isLoggedIn();
    final username = await _authService.getCurrentUser();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(username: username),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Hero(
          tag: 'logo',
          child: Image(
            image: AssetImage('assets/images/logo.png'),
            height: 200,
          ),
        ),
      ),
    );
  }
}