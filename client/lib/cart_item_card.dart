import 'package:flutter/material.dart';
import 'product.dart';
import 'cart_item_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TokenStorage.dart';
import 'access_refresh_auto.dart'; // добавь импорт утилиты

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class CartItemCard extends StatefulWidget {
  final CartItem cartItem;
  final VoidCallback? onQuantityChanged;

  const CartItemCard({super.key, required this.cartItem, this.onQuantityChanged});

  @override
  _CartItemCardState createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.cartItem.quantity;
  }

  Future<void> addOneToCart() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/cart/add');

    Future<http.Response> sendAddRequest(String? token) {
      return http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': widget.cartItem.product.id,
          'quantity': 1,
        }),
      );
    }

    String? accessToken = await TokenStorage.getAccessToken();
    http.Response response = await sendAddRequest(accessToken);

    if (response.statusCode == 403) {
      final refreshed = await AccessRefreshAuto.refreshAccessToken();
      if (refreshed) {
        final newAccessToken = await TokenStorage.getAccessToken();
        response = await sendAddRequest(newAccessToken);
      }
    }

    if (response.statusCode == 200) {
      setState(() {
        quantity += 1;
      });
      if (widget.onQuantityChanged != null) widget.onQuantityChanged!();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Добавлен 1 товар в корзину'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ошибка добавления: ${response.statusCode}'),
      ));
    }
  }

  Future<void> decreaseOneFromCart() async {
    if (quantity <= 0) return; // не уменьшаем меньше 1

    final url = Uri.parse('http://10.0.2.2:8080/api/cart/decrease');

    Future<http.Response> sendDecreaseRequest(String? token) {
      return http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': widget.cartItem.product.id,
          'quantity': 1,
        }),
      );
    }

    String? accessToken = await TokenStorage.getAccessToken();
    http.Response response = await sendDecreaseRequest(accessToken);

    if (response.statusCode == 403) {
      final refreshed = await AccessRefreshAuto.refreshAccessToken();
      if (refreshed) {
        final newAccessToken = await TokenStorage.getAccessToken();
        response = await sendDecreaseRequest(newAccessToken);
      }
    }

    if (response.statusCode == 200) {
      setState(() {
        quantity -= 1;
      });
      if (widget.onQuantityChanged != null) widget.onQuantityChanged!();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Уменьшено количество товара на 1'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ошибка уменьшения: ${response.statusCode}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CartItemDetailScreen(cartItem: widget.cartItem),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Image.network(
            widget.cartItem.product.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
          ),
          title: Text(widget.cartItem.product.name),
          subtitle: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: decreaseOneFromCart,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.remove_circle_outline, size: 24),
                ),
              ),
              Text('$quantity', style: const TextStyle(fontSize: 16)),
              GestureDetector(
                onTap: addOneToCart,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.add_circle_outline, size: 24),
                ),
              ),
            ],
          ),
          trailing: Text(
            'Цена: ${(widget.cartItem.price * quantity).toStringAsFixed(2)} ₽',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
