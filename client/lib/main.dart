import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter/rendering.dart';


void main() {
  // Отключает отладочную разметку
  debugPaintSizeEnabled = false;

  runApp(const ShoppingApp());
}

// class ShoppingApp extends StatelessWidget {
//   const ShoppingApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Shopping UI',
//       theme: ThemeData.dark(),
//       home: const HomeScreen(),
//     );
//   }
// }

// class Product {
//   final String id;
//   final String name;
//   final double price;
//   final String imageUrl;
//   final String? description;

//   Product({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.imageUrl,
//     this.description,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'],
//       name: json['name'],
//       price: (json['price'] as num).toDouble(),
//       imageUrl: json['imageUrl'],
//       description: json['description'],
//     );
//   }
// }

// class ProductResponse {
//   final List<Product> products;
//   final int totalProducts;
//   final int page;
//   final int size;
//   final bool hasNext;

//   ProductResponse({
//     required this.products,
//     required this.totalProducts,
//     required this.page,
//     required this.size,
//     required this.hasNext,
//   });

//   factory ProductResponse.fromJson(Map<String, dynamic> json) {
//     var productsJson = json['products'] as List;
//     List<Product> productsList = productsJson.map((p) => Product.fromJson(p)).toList();

//     return ProductResponse(
//       products: productsList,
//       totalProducts: json['totalProducts'],
//       page: json['page'],
//       size: json['size'],
//       hasNext: json['hasNext'],
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   List<Product> _products = [];
//   bool _loadingInitial = true;
//   bool _loadingMore = false;
//   int _currentPage = 0;
//   final int _pageSize = 4;
//   bool _hasNext = true;

//   bool _isAuthenticated = false;  // Статус авторизации

//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts(page: _currentPage);
//     _checkAuth();

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//               _scrollController.position.maxScrollExtent - 200 &&
//           !_loadingMore &&
//           _hasNext) {
//         _fetchMoreProducts();
//       }
//     });
//   }

//   Future<void> _checkAuth() async {
//     // TODO: Замени на реальную проверку токена из хранилища (SharedPreferences, SecureStorage и т.п.)
//     // Здесь просто пример с задержкой и false
//     await Future.delayed(const Duration(milliseconds: 200));
//     // Например, получение токена
//     String? token = await getAccessTokenFromStorage(); // Реализуй самостоятельно

//     setState(() {
//       _isAuthenticated = token != null && token.isNotEmpty;
//     });
//   }

//   Future<String?> getAccessTokenFromStorage() async {
//     // TODO: Реализуй получение токена из локального хранилища
//     // Пока заглушка — null (не авторизован)
//     return null;
//   }

//   Future<void> _fetchProducts({required int page}) async {
//     setState(() {
//       if (page == 0) {
//         _loadingInitial = true;
//       } else {
//         _loadingMore = true;
//       }
//     });

//     try {
//       final url = Uri.parse('http://10.0.2.2:8080/api/products?page=$page&size=$_pageSize');
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final utf8Body = utf8.decode(response.bodyBytes);
//         final jsonData = json.decode(utf8Body);
//         final productResponse = ProductResponse.fromJson(jsonData);

//         setState(() {
//           if (page == 0) {
//             _products = productResponse.products;
//           } else {
//             _products.addAll(productResponse.products);
//           }
//           _currentPage = productResponse.page;
//           _hasNext = productResponse.hasNext;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching products: $e');
//     } finally {
//       setState(() {
//         _loadingInitial = false;
//         _loadingMore = false;
//       });
//     }
//   }

//   Future<void> _fetchMoreProducts() async {
//     if (!_hasNext) return;
//     await _fetchProducts(page: _currentPage + 1);
//   }

//   void _onTabTapped(int index) async {
//     if (index == 3) {
//       await _checkAuth();
//     }
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: [
//           ProductScreen(
//             products: _products,
//             loadingInitial: _loadingInitial,
//             loadingMore: _loadingMore,
//             scrollController: _scrollController,
//           ),
//           const CategoryScreen(),
//           const CartScreen(),
//           _isAuthenticated ? const ProfileScreen() : const AuthScreen(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         backgroundColor: Colors.black,
//         selectedItemColor: Colors.purpleAccent,
//         unselectedItemColor: Colors.grey,
//         onTap: _onTabTapped,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Главная'),
//           BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Категории'),
//           BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Корзина'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
//         ],
//       ),
//     );
//   }
// }

// class ProductScreen extends StatelessWidget {
//   final List<Product> products;
//   final bool loadingInitial;
//   final bool loadingMore;
//   final ScrollController scrollController;

//   final TextEditingController _searchController = TextEditingController();

//   ProductScreen({
//     super.key,
//     required this.products,
//     required this.loadingInitial,
//     required this.loadingMore,
//     required this.scrollController,
//   });
//    Future<void> _addToCart(BuildContext context, String productId) async {
//     final token = await TokenStorage.getAccessToken();
//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Пожалуйста, авторизуйтесь'),
//       ));
//       return;
//     }

//     final url = Uri.parse('http://10.0.2.2:8080/api/cart/add');
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         'productId': productId,
//         'quantity': 1,
//       }),
//     );

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Товар добавлен в корзину'),
//       ));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Ошибка ${response.statusCode}'),
//       ));
//     }
//   }

//   void _onSearch(BuildContext context) {
//     final query = _searchController.text.trim();
//     if (query.isNotEmpty) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => SearchScreen(query: query),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         children: [
//           // Поисковая строка
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Поиск товаров...',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                       filled: true,
//                       fillColor: Colors.white12,
//                     ),
//                     onSubmitted: (_) => _onSearch(context),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () => _onSearch(context),
//                 ),
//               ],
//             ),
//           ),
//           // Товары
//           Expanded(
//             child: loadingInitial
//                 ? const Center(child: CircularProgressIndicator())
//                 : GridView.builder(
//                     controller: scrollController,
//                     padding: const EdgeInsets.all(8),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisSpacing: 10,
//                       crossAxisSpacing: 10,
//                       childAspectRatio: 0.75,
//                     ),
//                     itemCount: loadingMore ? products.length + 1 : products.length,
//                     itemBuilder: (context, index) {
//                       if (index >= products.length) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       final product = products[index];
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ProductDetailScreen(product: product),
//                             ),
//                           );
//                         },
//                         child: Card(
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Expanded(
//                                 child: ClipRRect(
//                                   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                                   child: Image.network(
//                                     product.imageUrl,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//                                     const SizedBox(height: 4),
//                                     Text('${product.price.toStringAsFixed(2)} ₽',
//                                         style: const TextStyle(color: Colors.grey)),
//                                   ],
//                                 ),
//                               ),
//                              Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: ElevatedButton.icon(
//                                   icon: const Icon(Icons.add_shopping_cart, size: 20),
//                                   label: const Text('В корзину'),
//                                   onPressed: () => _addToCart(context, product.id),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
