import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'TokenStorage.dart';
import 'access_refresh_auto.dart';
import 'cart_item_card.dart'; // Убедись, что здесь нет второй реализации CartItemCard
import 'delivery_screen.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  bool _isUnauthorized = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _isUnauthorized = false;
    });

    String? token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      setState(() {
        _isUnauthorized = true;
        _isLoading = false;
      });
      return;
    }

    bool success = await _fetchCart(token);

    if (!success) {
      bool refreshed = await AccessRefreshAuto.refreshAccessToken();
      if (refreshed) {
        token = await TokenStorage.getAccessToken();
        if (token == null || token.isEmpty) {
          setState(() {
            _isUnauthorized = true;
            _isLoading = false;
          });
          return;
        }

        bool secondTry = await _fetchCart(token);
        setState(() {
          _isUnauthorized = !secondTry;
        });
      } else {
        setState(() {
          _isUnauthorized = true;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _fetchCart(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final utf8Body = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(utf8Body);

        List<CartItem> cartItems =
            data.map((json) => CartItem.fromJson(json)).toList();

        setState(() {
          _cartItems = cartItems;
        });
        return true;
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        return false;
      } else {
        debugPrint('Ошибка получения корзины: ${response.statusCode}');
        return true; // Не авторизационная ошибка
      }
    } catch (e) {
      debugPrint('Ошибка сети: $e');
      return true;
    }
  }

  Future<void> _printTokens() async {
    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();

    debugPrint('Access Token: $accessToken');
    debugPrint('Refresh Token: $refreshToken');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Токены напечатаны в консоль')),
    );
  }

  void _proceedToDelivery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeliveryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isUnauthorized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Чтобы воспользоваться корзиной, необходимо авторизоваться',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _printTokens,
              child: const Text('Авторизироваться'),
            ),
          ],
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Корзина пуста'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _printTokens,
              child: const Text('Авторизироваться'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return CartItemCard(cartItem: _cartItems[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _printTokens,
                child: const Text('Авторизироваться'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _proceedToDelivery,
                icon: const Icon(Icons.local_shipping),
                label: const Text('Перейти к оформлению'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color.fromARGB(255, 63, 97, 64),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
