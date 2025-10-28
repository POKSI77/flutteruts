import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book.dart';

// -------------------------------------------------------------------
// Class CartItem (Ini sama seperti yang Anda miliki)
// Kita simpan di file yang sama untuk kemudahan
// -------------------------------------------------------------------
class CartItem {
  final String id;
  final String title;
  final String image;
  final double price;
  int quantity;

  // Tambahan: data buku lengkap untuk memudahkan
  final Book bookData; 

  CartItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.quantity = 1,
    required this.bookData, // Tambahkan ini
  });

  // Factory dan toJson sekarang juga menangani bookData
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        title: json['title'],
        image: json['image'],
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'],
        // Ambil data buku lengkap dari field 'bookData'
        bookData: Book.fromJson(json['bookData'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'price': price,
        'quantity': quantity,
        // Simpan data buku lengkap
        'bookData': bookData.toJson(),
      };
}


// -------------------------------------------------------------------
// Class CartModel (Ini adalah Logika Baru dengan Firestore)
// -------------------------------------------------------------------
class CartModel with ChangeNotifier {
  // Dapatkan instance Firebase
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Helper untuk mendapatkan UID pengguna saat ini
  String? get _uid => _auth.currentUser?.uid;

  // Helper untuk mendapatkan path koleksi 'cart' milik pengguna
  CollectionReference<Map<String, dynamic>>? get _cartCollection {
    if (_uid == null) return null;
    return _db.collection('users').doc(_uid).collection('cart');
  }

  // ---- TIDAK ADA LAGI loadCart() atau saveCart() ----
  // Itu semua akan ditangani oleh StreamBuilder di cart_screen.dart


  // --- FUNGSI-FUNGSI BARU UNTUK MEMODIFIKASI FIRESTORE ---

  Future<void> addItem(Book book) async {
    if (_cartCollection == null) return;

    // Gunakan ID buku sebagai ID dokumen di koleksi 'cart'
    final docRef = _cartCollection!.doc(book.id);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      // Jika buku sudah ada, tambahkan quantity
      int newQuantity = docSnap.data()?['quantity'] + 1;
      await docRef.update({'quantity': newQuantity});
    } else {
      // Jika buku baru, buat CartItem baru
      final newCartItem = CartItem(
        id: book.id,
        title: book.title,
        image: book.imageUrl,
        price: book.getDisplayPriceValue(), // Gunakan harga yang benar
        quantity: 1, // Kuantitas awal
        bookData: book, // Simpan data buku lengkap
      );
      // Simpan ke Firestore
      await docRef.set(newCartItem.toJson());
    }
    // Tidak perlu notifyListeners(), StreamBuilder akan update otomatis
  }

  Future<void> removeItem(Book book) async {
    if (_cartCollection == null) return;
    
    // Hapus dokumen dengan ID buku
    await _cartCollection!.doc(book.id).delete();
  }

  Future<void> decrementQuantity(Book book) async {
    if (_cartCollection == null) return;

    final docRef = _cartCollection!.doc(book.id);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      int currentQuantity = docSnap.data()?['quantity'];
      if (currentQuantity > 1) {
        // Jika kuantitas > 1, kurangi 1
        await docRef.update({'quantity': currentQuantity - 1});
      } else {
        // Jika kuantitas 1, hapus item
        await docRef.delete();
      }
    }
  }

  Future<void> clearCart() async {
    if (_cartCollection == null) return;

    // Ambil semua item di keranjang
    final snapshot = await _cartCollection!.get();
    
    // Hapus semua dokumen satu per satu menggunakan "batch"
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
}