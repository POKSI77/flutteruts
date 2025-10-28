import 'package:firebase_auth/firebase_auth.dart'; // Tetap diperlukan untuk User object
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/favorite_model.dart';
// import '../models/cart_model.dart'; // CartModel tidak lagi diperlukan di sini
import 'home_screen.dart';

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

 final _formKey = GlobalKey<FormState>();
 final _emailController = TextEditingController();
 final _passwordController = TextEditingController();
 final _confirmPasswordController = TextEditingController();
 final _usernameController = TextEditingController();

 bool _isLoading = false;

 @override
 void initState() {
   super.initState();
   _animationController = AnimationController(
     vsync: this,
     duration: const Duration(milliseconds: 300),
   );
   _loadPreviousUser();
 }

 Future<void> _loadPreviousUser() async {
   final prefs = await SharedPreferences.getInstance();
   final previousUser = prefs.getString('email');
   if (previousUser != null && mounted) {
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
   if (!mounted) return;
   setState(() {
     if (isLogin) {
       _animationController.forward();
     } else {
       _animationController.reverse();
     }
     isLogin = !isLogin;
   });

   _formKey.currentState?.reset();
   _emailController.clear();
   _passwordController.clear();
   _confirmPasswordController.clear();
   _usernameController.clear();
 }

 // --- FUNGSI INI DIPERBAIKI LAGI ---
 Future<void> _handleSubmit() async {
   if (!_formKey.currentState!.validate()) {
     return;
   }

   if (!mounted) return;
   setState(() => _isLoading = true);

   final authService = Provider.of<AuthService>(context, listen: false);

   try {
     if (isLogin) {
       // --- BLOK LOGIN ---
       // Panggil method 'login' yang benar (mengembalikan bool)
       final bool loginSuccess = await authService.login(
         _emailController.text.trim(),
         _passwordController.text.trim(),
       );

       if (loginSuccess) {
         // Ambil user object dari FirebaseAuth setelah login sukses
         final User? user = FirebaseAuth.instance.currentUser;
         final userEmail = user?.email; // Email dari Firebase Auth

         if (userEmail != null) {
           // SharedPreferences sudah di-set di dalam authService.login
           // final prefs = await SharedPreferences.getInstance();
           // await prefs.setString('email', userEmail); // Tidak perlu lagi

           if (mounted) {
             final favoriteModel =
                 Provider.of<FavoriteModel>(context, listen: false);
             // Asumsi FavoriteModel masih pakai setUser(email)
             await favoriteModel.setUser(userEmail);
           }

           if (!mounted) return;
           Navigator.of(context).pushReplacement(
             MaterialPageRoute(
               // Kirim username dari SharedPreferences yang disimpan oleh login
               builder: (context) => HomeScreen(username: user?.displayName), // Atau ambil dari prefs jika perlu
             ),
           );
           return;
         } else {
           _showError('Login sukses, tapi gagal mendapatkan info pengguna.');
         }
       } else {
         // authService.login() seharusnya throw Exception jika gagal
         // Jadi baris ini mungkin tidak tercapai, tapi jaga-jaga
         _showError('Login gagal. Periksa email/password.');
       }
     } else {
       // --- BLOK REGISTER ---
       // Panggil method 'register' yang benar (mengembalikan void)
       await authService.register(
         _usernameController.text.trim(),
         _emailController.text.trim(),
         _passwordController.text.trim(),
       );

       // Setelah register sukses, user otomatis login di Firebase Auth
       final User? registeredUser = FirebaseAuth.instance.currentUser;
       final registeredEmail = registeredUser?.email;

       if (registeredEmail != null) {
           // SharedPreferences sudah di-set di dalam authService.register
           // final prefs = await SharedPreferences.getInstance();
           // await prefs.setString('email', registeredEmail); // Tidak perlu lagi

           _showSuccess('Registrasi berhasil! Silakan login.');
           _toggleForm(); // Kembali ke form login
       } else {
          _showError('Registrasi berhasil, tapi gagal mendapatkan info pengguna.');
          _toggleForm(); // Tetap kembali ke login
       }
     }
   } on FirebaseAuthException catch (e) { // Tangkap error Firebase
     _showError(e.message ?? "Terjadi error autentikasi.");
   } on Exception catch (e) { // Tangkap Exception dari AuthService
      // Ambil pesan dari Exception yang dilempar oleh AuthService
      _showError(e.toString().replaceFirst('Exception: ', '')); // Hapus prefix "Exception: "
   } catch (e) { // Tangkap error lainnya
     _showError("Terjadi kesalahan tidak terduga: ${e.toString()}");
   } finally {
     if (mounted) {
       setState(() => _isLoading = false);
     }
   }
 }
 // --- AKHIR PERBAIKAN ---


 void _showError(String message) {
   if (!mounted) return;
   ScaffoldMessenger.of(context).removeCurrentSnackBar();
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text(message), backgroundColor: Colors.red),
   );
 }

 void _showSuccess(String message) {
   if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text(message), backgroundColor: Colors.green),
   );
 }

 @override
 Widget build(BuildContext context) {
   // (Kode UI Anda di sini tidak berubah)
    return Scaffold(
     body: Container(
       decoration: const BoxDecoration(
         gradient: LinearGradient(
           colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
         ),
       ),
       child: SafeArea(
         child: Center(
           child: SingleChildScrollView(
             padding: const EdgeInsets.all(24.0),
             child: Container(
               decoration: BoxDecoration(
                 color: Colors.white.withOpacity(0.95),
                 borderRadius: BorderRadius.circular(16),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.1),
                     blurRadius: 15,
                     offset: const Offset(0, 8),
                   ),
                    BoxShadow(
                     color: const Color(0xFF2575FC).withOpacity(0.4),
                     blurRadius: 60,
                     spreadRadius: 5,
                     offset: const Offset(0, 20),
                   ),
                    BoxShadow(
                     color: const Color(0xFF6A11CB).withOpacity(0.3),
                     blurRadius: 60,
                     spreadRadius: 5,
                     offset: const Offset(0, -20),
                   ),
                 ],
               ),
               child: Padding(
                 padding: const EdgeInsets.all(24.0),
                 child: Form(
                   key: _formKey,
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Hero(
                         tag: 'logo',
                         child: SizedBox(
                           height: 90,
                           width: 90,
                           child: CircleAvatar(
                             backgroundImage:
                                 const AssetImage('assets/images/logo.png'),
                             backgroundColor: Colors.transparent,
                           ),
                         ),
                       ),
                       const SizedBox(height: 20),
                       Text(
                         isLogin ? 'Welcome !' : 'Create Account',
                         style: Theme.of(context)
                             .textTheme
                             .headlineSmall
                             ?.copyWith(
                               fontWeight: FontWeight.bold,
                               color: Colors.black87,
                             ),
                       ),
                       const SizedBox(height: 6),
                        Text(
                         isLogin
                             ? 'Sign in to continue'
                             : 'Register to get started',
                         style: TextStyle(color: Colors.grey[600]),
                       ),
                       const SizedBox(height: 30),
                       if (!isLogin) ...[
                         TextFormField(
                           controller: _usernameController,
                           decoration:
                               _inputDecoration('Username', Icons.person),
                           validator: (v) => v == null || v.trim().length < 3
                               ? 'Min 3 characters'
                               : null,
                         ),
                         const SizedBox(height: 16),
                       ],
                       TextFormField(
                         controller: _emailController,
                         decoration: _inputDecoration(
                             isLogin ? 'Username or Email' : 'Email',
                             Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                         validator: (v) {
                           if (v == null || v.trim().isEmpty) {
                             return 'Please enter ${isLogin ? "username/email" : "email"}';
                           }
                           if (!v.contains('@') || !v.contains('.')) {
                             return 'Please enter a valid email address';
                           }
                           return null;
                         },
                       ),
                       const SizedBox(height: 16),
                       TextFormField(
                         controller: _passwordController,
                         obscureText: !_passwordVisible,
                         decoration:
                             _inputDecoration('Password', Icons.lock).copyWith(
                           suffixIcon: IconButton(
                             icon: Icon(
                               _passwordVisible
                                   ? Icons.visibility
                                   : Icons.visibility_off,
                               color: Colors.grey,
                             ),
                             onPressed: () => setState(
                                 () => _passwordVisible = !_passwordVisible),
                           ),
                         ),
                         validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter password';
                            }
                            if (v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                       ),
                       if (!isLogin) ...[
                         const SizedBox(height: 16),
                         TextFormField(
                           controller: _confirmPasswordController,
                           obscureText: !_confirmPasswordVisible,
                           decoration:
                               _inputDecoration('Confirm Password', Icons.lock)
                                   .copyWith(
                             suffixIcon: IconButton(
                               icon: Icon(
                                 _confirmPasswordVisible
                                     ? Icons.visibility
                                     : Icons.visibility_off,
                                 color: Colors.grey,
                               ),
                               onPressed: () => setState(() =>
                                   _confirmPasswordVisible =
                                       !_confirmPasswordVisible),
                             ),
                           ),
                            validator: (v) {
                             if (v == null || v.isEmpty) {
                               return 'Please confirm your password';
                             }
                             if (v != _passwordController.text) {
                               return 'Passwords do not match';
                             }
                             return null;
                           },
                         ),
                       ],
                       const SizedBox(height: 24),
                       SizedBox(
                         width: double.infinity,
                         height: 50,
                         child: DecoratedBox(
                           decoration: BoxDecoration(
                              gradient: const LinearGradient(
                               colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
                               begin: Alignment.centerLeft,
                               end: Alignment.centerRight,
                             ),
                             borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.2),
                                 blurRadius: 10,
                                 offset: const Offset(0, 5),
                               ),
                             ],
                           ),
                           child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.transparent,
                               shadowColor: Colors.transparent,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(12),
                               ),
                             ),
                             onPressed: _isLoading ? null : _handleSubmit,
                             child: _isLoading
                                 ? const SizedBox(
                                    width: 22,
                                     height: 22,
                                     child: CircularProgressIndicator(
                                       color: Colors.white,
                                       strokeWidth: 2,
                                     ),
                                   )
                                 : Text(
                                    isLogin ? 'Login' : 'Register',
                                     style: const TextStyle(
                                         fontSize: 16,
                                         color: Colors.white,
                                         fontWeight: FontWeight.bold),
                                   ),
                           ),
                         ),
                       ),
                       const SizedBox(height: 16),
                       TextButton(
                         onPressed: _isLoading ? null : _toggleForm,
                         child: Text(
                            isLogin
                               ? "Don't have an account? Register"
                               : "Already have an account? Login",
                           style: TextStyle(
                             color: Theme.of(context).primaryColor,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
             ),
           ),
         ),
       ),
     ),
   );
 }

 InputDecoration _inputDecoration(String label, IconData icon) {
   // (Fungsi ini tidak berubah)
    return InputDecoration(
     labelText: label,
     prefixIcon: Icon(icon, color: Colors.grey[700]),
     filled: true,
     fillColor: Colors.grey[50],
     border: OutlineInputBorder(
       borderRadius: BorderRadius.circular(12),
       borderSide: BorderSide.none,
     ),
     focusedBorder: OutlineInputBorder(
       borderRadius: BorderRadius.circular(12),
       borderSide: const BorderSide(color: Color(0xFF2575FC), width: 2),
     ),
     enabledBorder: OutlineInputBorder(
       borderRadius: BorderRadius.circular(12),
       borderSide: BorderSide(color: Colors.grey[300]!),
     ),
     errorBorder: OutlineInputBorder(
       borderRadius: BorderRadius.circular(12),
       borderSide: const BorderSide(color: Colors.red, width: 1),
     ),
     focusedErrorBorder: OutlineInputBorder(
       borderRadius: BorderRadius.circular(12),
       borderSide: const BorderSide(color: Colors.red, width: 2),
     ),
   );
 }
}