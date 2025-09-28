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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  late AnimationController _controller;
  final String _title = "PokBook";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 4));

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_title.length, (index) {
        final animation = Tween<Offset>(
          begin: const Offset(0, 1), // mulai dari bawah (logo)
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              index * 0.1, // delay per huruf
              1.0,
              curve: Curves.elasticOut, // efek loncat lucu
            ),
          ),
        );

        final fade = CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeIn),
        );

        return SlideTransition(
          position: animation,
          child: FadeTransition(
            opacity: fade,
            child: Text(
              _title[index],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Tengah: Logo + animasi teks keluar dari logo
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Hero(
                      tag: 'logo',
                      child: Image(
                        image: AssetImage('assets/images/logo.png'),
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedText(), // huruf loncat keluar
                  ],
                ),
              ),
            ),

            // Bawah: credit
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "by : muhammad dwi saputra",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
