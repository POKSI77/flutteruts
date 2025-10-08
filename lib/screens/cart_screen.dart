// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../models/cart_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Consumer<CartModel>(
          builder: (context, cart, _) {
            return Text(
              'Cart (${cart.items.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        backgroundColor: const Color(0xFF667eea),
        actions: [
          Consumer<CartModel>(
            builder: (context, cart, _) {
              if (cart.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Clear Cart"),
                        content: const Text("Are you sure you want to remove all items?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              cart.clearCart();
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Cart cleared"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text("Yes, Clear"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const EmptyCartView();
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemCard(item: item);
                    },
                  ),
                ),
                CartSummary(totalPrice: currencyFormatter.format(cart.totalPrice)),
              ],
            );
          }
        },
      ),
    );
  }
}

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text("Your cart is empty", style: TextStyle(fontSize: 20, color: Colors.grey)),
          SizedBox(height: 10),
          Text("Add some books to get started!", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);
    
    // Perbaikan: Ubah variabel book menjadi item
    final tempBook = Book(
      id: item.id,
      title: item.title,
      author: '', // Tidak ada author di CartItem
      price: item.price,
      imageUrl: item.image,
      description: '', // Tidak ada deskripsi di CartItem
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Image.network(
              item.image,
              width: 80,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.book, size: 80, color: Colors.grey),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Rp ${item.price.toStringAsFixed(0)}', 
                      style: const TextStyle(color: Color(0xFF667eea), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        onPressed: () => cart.decrementQuantity(tempBook),
                      ),
                      Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () => cart.addItem(tempBook),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => cart.removeItem(tempBook),
            ),
          ],
        ),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final String totalPrice;
  const CartSummary({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(totalPrice,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF667eea))),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Checkout"),
                  content: const Text("Proceed to payment?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                    ElevatedButton(
                      onPressed: () {
                        cart.clearCart();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order placed successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Checkout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}