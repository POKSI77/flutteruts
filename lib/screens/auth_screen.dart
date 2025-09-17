import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadPreviousUser();
  }

  Future<void> _loadPreviousUser() async {
    final prefs = await SharedPreferences.getInstance();
    final previousUser = prefs.getString('username');
    if (previousUser != null) {
      _emailController.text = previousUser;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      if (isLogin) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      isLogin = !isLogin;
    });
    // Kosongkan controller saat beralih mode
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _usernameController.clear();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (isLogin) {
          final isRegistered =
              await _authService.isUserRegistered(_emailController.text);
          if (!isRegistered) {
            _showError('Account not registered. Please register first.');
            return;
          }

          final success = await _authService.login(
            _emailController.text,
            _passwordController.text,
          );

          if (success) {
            final prefs = await SharedPreferences.getInstance();
            String username = _emailController.text.trim();
            if (username.contains('@gmail.com')) {
              username = username.split('@').first;
            }

            // Simpan status login
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('username', username);

            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(username: username),
              ),
            );
          } else {
            _showError('Invalid username/email or password');
          }
        } else {
          await _authService.register(
            _usernameController.text,
            _emailController.text,
            _passwordController.text,
          );
          _showSuccess('Registration successful! Please login.');
          _toggleForm();
        }
      } catch (e) {
        _showError(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Hero(
                    tag: 'logo',
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isLogin ? 'Welcome Back!' : 'Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin ? 'Sign in to continue' : 'Register to get started',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isLogin) ...[
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 3) {
                                  return 'Username must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText:
                                  isLogin ? 'Username or Email' : 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isLogin
                                    ? 'Please enter username or email'
                                    : 'Please enter email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          if (isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                          if (!isLogin) ...[
                            const SizedBox(height: 16),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(_slideAnimation),
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_confirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _confirmPasswordVisible =
                                            !_confirmPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleSubmit,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : Text(isLogin ? 'Login' : 'Register'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _toggleForm,
                            child: Text(
                              isLogin
                                  ? 'Don\'t have an account? Register'
                                  : 'Already have an account? Login',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}