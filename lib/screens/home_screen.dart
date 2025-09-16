import 'package:flutter/material.dart';
import '../models/book.dart';
import 'cart_screen.dart';
import 'book_detail_screen.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';

// Home Screen
class HomeScreen extends StatefulWidget {
  final String? username;

  const HomeScreen({
    Key? key,
    this.username,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Book> cartItems = [];
  final AuthService _authService = AuthService();

  void addToCart(Book book) {
    setState(() {
      cartItems.add(book);
    });
  }

  void removeFromCart(Book book) {
    setState(() {
      cartItems.remove(book);
    });
  }

  final List<Book> books = const [
    Book(
      id: '1',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      price: 9.99,
      imageUrl: 'https://example.com/gatsby.jpg',
      description: 'A story of decadence and excess...',
    ),
    Book(
      id: '2',
      title: '1984',
      author: 'George Orwell',
      price: 12.99,
      imageUrl: 'https://example.com/1984.jpg',
      description: 'A dystopian social science fiction...',
    ),
        Book(
      id: '3',
      title: '1984',
      author: 'George Orwell',
      price: 12.99,
      imageUrl: 'https://example.com/1984.jpg',
      description: 'A dystopian social science fiction...',
    ),
        Book(
      id: '4',
      title: '1984',
      author: 'George Orwell',
      price: 12.99,
      imageUrl: 'https://example.com/1984.jpg',
      description: 'A dystopian social science fiction...',
    ),
        Book(
      id: '5',
      title: '1984',
      author: 'George Orwell',
      price: 12.99,
      imageUrl: 'https://example.com/1984.jpg',
      description: 'A dystopian social science fiction...',
    ),
    // Add more books as needed
  ];
String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour >= 0 && hour < 12) {
    return "Selamat pagi";
  } else if (hour >= 12 && hour < 15) {
    return "Selamat siang";
  } else if (hour >= 15 && hour < 18) {
    return "Selamat sore";
  } else {
    return "Selamat malam";
  }
}

  String? _welcomeMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
  final username = widget.username ?? await _authService.getCurrentUser();
  final greeting = _getGreeting();
  setState(() {
    _welcomeMessage = '$greeting, ${username ?? "User"}!';
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
      await _authService.logout();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookstore'),
        actions: [
          // Cart Icon
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartItems.isNotEmpty)
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
                        '${cartItems.length}',
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
                  builder: (context) => CartScreen(
                    cartItems: cartItems,
                    onRemoveFromCart: removeFromCart,
                  ),
                ),
              );
            },
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Add welcome message container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Text(
              _welcomeMessage ?? 'Loading...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return BookCard(book: books[index], onAddToCart: addToCart);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  final void Function(Book) onAddToCart;

  const BookCard({Key? key, required this.book, required this.onAddToCart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: book),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                book.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.book));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    book.author,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '\$${book.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onAddToCart(book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${book.title} added to cart!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Add to Cart'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
