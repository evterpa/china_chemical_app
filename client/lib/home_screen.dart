import 'package:flutter/material.dart';
import 'product.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile_screen.dart';
import 'auth_screen.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import 'product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Product> _products = [];
  bool _loadingInitial = true;
  bool _loadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 4;
  bool _hasNext = true;

  bool _isAuthenticated = false;  // Статус авторизации

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProducts(page: _currentPage);
    _checkAuth();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_loadingMore &&
          _hasNext) {
        _fetchMoreProducts();
      }
    });
  }

  Future<void> _checkAuth() async {
    // TODO: Замени на реальную проверку токена из хранилища (SharedPreferences, SecureStorage и т.п.)
    await Future.delayed(const Duration(milliseconds: 200));
    String? token = await getAccessTokenFromStorage(); // Реализуй самостоятельно

    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
    });
  }

  Future<String?> getAccessTokenFromStorage() async {
    // TODO: Реализуй получение токена из локального хранилища
    return null;
  }

  Future<void> _fetchProducts({required int page}) async {
    setState(() {
      if (page == 0) {
        _loadingInitial = true;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/products?page=$page&size=$_pageSize');
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
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      setState(() {
        _loadingInitial = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _fetchMoreProducts() async {
    if (!_hasNext) return;
    await _fetchProducts(page: _currentPage + 1);
  }

  void _onTabTapped(int index) async {
    if (index == 3) {
      await _checkAuth();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    switch (_selectedIndex) {
      case 0:
        bodyContent = ProductScreen(
          products: _products,
          loadingInitial: _loadingInitial,
          loadingMore: _loadingMore,
          scrollController: _scrollController,
        );
        break;
      case 1:
        bodyContent = const CategoryScreen();
        break;
      case 2:
        // Ленивое создание CartScreen каждый раз при выборе вкладки
        bodyContent = const CartScreen();
        break;
      case 3:
        // Ленивое создание профиля или экрана авторизации при выборе вкладки
        bodyContent = _isAuthenticated ? const ProfileScreen() : const AuthScreen();
        break;
      default:
        bodyContent = Container();
    }

    return Scaffold(
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Категории'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Корзина'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
