import 'product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TokenStorage.dart';
import 'search_screen.dart';
import 'product_detail_screen.dart';


class ProductScreen extends StatelessWidget {
  final List<Product> products;
  final bool loadingInitial;
  final bool loadingMore;
  final ScrollController scrollController;

  final TextEditingController _searchController = TextEditingController();

  ProductScreen({
    super.key,
    required this.products,
    required this.loadingInitial,
    required this.loadingMore,
    required this.scrollController,
  });
   Future<void> _addToCart(BuildContext context, String productId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Пожалуйста, авторизуйтесь'),
      ));
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/api/cart/add');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
        'quantity': 1,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Товар добавлен в корзину'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ошибка ${response.statusCode}'),
      ));
    }
  }

  void _onSearch(BuildContext context) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchScreen(query: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск товаров...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white12,
                    ),
                    onSubmitted: (_) => _onSearch(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _onSearch(context),
                ),
              ],
            ),
          ),
          // Товары
          Expanded(
            child: loadingInitial
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: loadingMore ? products.length + 1 : products.length,
                    itemBuilder: (context, index) {
                      if (index >= products.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('${product.price.toStringAsFixed(2)} ₽',
                                        style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                             Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                                  label: const Text('В корзину'),
                                  onPressed: () => _addToCart(context, product.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
