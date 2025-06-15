import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_detail_screen.dart';
import 'product.dart';

class SearchScreen extends StatefulWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Product> _products = [];
  int _currentPage = 0;
  final int _pageSize = 10; // можно поменять размер страницы по желанию
  bool _hasNext = true;
  bool _loadingInitial = true;
  bool _loadingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchSearchResults(page: 0);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_loadingMore &&
          _hasNext) {
        _fetchMoreResults();
      }
    });
  }

  Future<void> _fetchSearchResults({required int page}) async {
    setState(() {
      if (page == 0) {
        _loadingInitial = true;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final url = Uri.parse(
          'http://10.0.2.2:8080/api/products/search?query=${Uri.encodeComponent(widget.query)}&page=$page&size=$_pageSize');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final utf8Body = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(utf8Body);
        final productResponse = ProductResponse.fromJson(jsonData);

        setState(() {
          if (page == 0) {
            _products = productResponse.products;
          } else {
            _products.addAll(productResponse.products);
          }
          _currentPage = productResponse.page;
          _hasNext = productResponse.hasNext;
        });
      } else {
        // Если ошибка, прекращаем загрузку
        setState(() {
          _hasNext = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching search results: $e');
    } finally {
      setState(() {
        _loadingInitial = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _fetchMoreResults() async {
    if (!_hasNext || _loadingMore) return;
    await _fetchSearchResults(page: _currentPage + 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Результаты поиска: "${widget.query}"')),
      body: _loadingInitial
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('Ничего не найдено'))
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _loadingMore ? _products.length + 1 : _products.length,
                  itemBuilder: (context, index) {
                    if (index >= _products.length) {
                      // Индикатор загрузки при подгрузке
                      return const Center(child: CircularProgressIndicator());
                    }

                    final product = _products[index];
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
