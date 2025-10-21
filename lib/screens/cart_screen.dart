import 'package:bookstore_app/models/book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/cart_model.dart';
import '../main.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<CartModel>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDark;

    final List<Color> appBarGradientColors = [
      isDarkMode ? Colors.black : Colors.white,
      isDarkMode
          ? Colors.grey.shade900
          : const Color.fromARGB(255, 159, 200, 216),
    ];
    final Color appBarTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color appBarIconColor = isDarkMode ? Colors.white : Colors.black;
    final Color bodyBackgroundColor =
        isDarkMode ? const Color(0xFF121212) : Colors.grey.shade100;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subtleTextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color cardBackgroundColor =
        isDarkMode ? Colors.grey.shade800 : Colors.white;
    final Color blueColor = Colors.blue[700]!;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: bodyBackgroundColor,
      appBar: AppBar(
        title: Consumer<CartModel>(
          builder: (context, cartData, _) {
            return Text(
              'Cart (${cartData.items.length})',
              style: TextStyle(
                color: appBarTextColor,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: appBarIconColor),
        elevation: 4,
        actions: [
          Consumer<CartModel>(
            builder: (context, cartData, _) {
              if (cartData.items.isNotEmpty) {
                return IconButton(
                  icon: Icon(Icons.delete_sweep, color: appBarIconColor),
                  tooltip: 'Clear Cart',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Clear Cart"),
                        content: const Text(
                            "Are you sure you want to remove all items?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent),
                            onPressed: () {
                              cartData.clearCart();
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
        builder: (context, cartData, _) {
          if (cartData.items.isEmpty) {
            return EmptyCartView(textColor: subtleTextColor);
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: cartData.items.length,
                    itemBuilder: (context, index) {
                      final item = cartData.items[index];
                      return CartItemCard(
                        item: item,
                        currencyFormatter: currencyFormatter,
                        cardColor: cardBackgroundColor,
                        textColor: textColor,
                        subtleTextColor: subtleTextColor,
                        blueColor: blueColor,
                      );
                    },
                  ),
                ),
                CartSummary(
                  totalPrice: currencyFormatter.format(cartData.totalPrice),
                  backgroundColor: cardBackgroundColor,
                  textColor: textColor,
                  blueColor: blueColor,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class EmptyCartView extends StatelessWidget {
  final Color textColor;
  const EmptyCartView({super.key, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: textColor),
          const SizedBox(height: 20),
          Text(
            "Your cart is empty",
            style: TextStyle(fontSize: 20, color: textColor),
          ),
          const SizedBox(height: 10),
          Text(
            "Add some books to get started!",
            // ignore: deprecated_member_use
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final NumberFormat currencyFormatter;
  final Color cardColor;
  final Color textColor;
  final Color subtleTextColor;
  final Color blueColor;

  const CartItemCard({
    super.key,
    required this.item,
    required this.currencyFormatter,
    required this.cardColor,
    required this.textColor,
    required this.subtleTextColor,
    required this.blueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);

    final tempBook = Book(
      id: item.id,
      title: item.title,
      author: '',
      price: item.price,
      imageUrl: item.image,
      description: '',
    );

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                item.image,
                width: 70,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 100,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.book,
                        size: 40, color: Colors.grey.shade700)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currencyFormatter.format(item.price),
                    style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => cart.decrementQuantity(tempBook),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              border: Border.all(
                                  // ignore: deprecated_member_use
                                  color: Colors.redAccent.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.remove,
                              size: 18, color: Colors.redAccent),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      InkWell(
                        onTap: () => cart.addItem(tempBook),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              border: Border.all(
                                  // ignore: deprecated_member_use
                                  color: Colors.green.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.add,
                              size: 18, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
                // ignore: deprecated_member_use
                icon: Icon(Icons.delete_outline,
                    // ignore: deprecated_member_use
                    color: Colors.redAccent.withOpacity(0.8)),
                tooltip: 'Remove item',
                onPressed: () {
                  cart.removeItem(tempBook);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.title} removed from cart.')),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final String totalPrice;
  final Color backgroundColor;
  final Color textColor;
  final Color blueColor;

  const CartSummary({
    super.key,
    required this.totalPrice,
    required this.backgroundColor,
    required this.textColor,
    required this.blueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              Text(
                totalPrice,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Checkout"),
                  content: Text("Proceed to payment for $totalPrice?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
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
                backgroundColor: blueColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            child: const Text("Checkout"),
          ),
        ],
      ),
    );
  }
}
