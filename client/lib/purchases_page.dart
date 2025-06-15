import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'TokenStorage.dart'; // обязательно этот импорт

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'TokenStorage.dart'; // обязательно этот импорт

// Модели для парсинга JSON
class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
      );
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final Category category;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stockQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'],
        category: Category.fromJson(json['category']),
        stockQuantity: json['stockQuantity'],
      );
}

class Item {
  final String id;
  final Product product;
  final int quantity;

  Item({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'],
        product: Product.fromJson(json['product']),
        quantity: json['quantity'],
      );
}

class Purchase {
  final String id;
  final String userId;
  final List<Item> items;

  Purchase({
    required this.id,
    required this.userId,
    required this.items,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json['id'],
        userId: json['userId'],
        items: (json['items'] as List)
            .map((itemJson) => Item.fromJson(itemJson))
            .toList(),
      );
}



class PurchasesPage extends StatefulWidget {
  const PurchasesPage({Key? key}) : super(key: key);

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  late Future<List<Purchase>> _purchasesFuture;

  @override
  void initState() {
    super.initState();
    _purchasesFuture = fetchPurchases();
  }

  Future<List<Purchase>> fetchPurchases() async {
    final token = await TokenStorage.getAccessToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/purchases/my'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonData = json.decode(utf8Body);
      return jsonData.map((json) => Purchase.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load purchases');
    }
  }

  Future<void> _showSupportDialog() async {
    final TextEditingController textController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Обратиться в поддержку'),
        content: TextField(
          controller: textController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Введите ваш вопрос или сообщение',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите текст сообщения')),
                );
                return;
              }
              Navigator.of(context).pop(true); // Закроем диалог сразу
              await _sendSupportRequest(text);
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );

    // Можно обработать result если нужно
  }

  Future<void> _sendSupportRequest(String text) async {
    final token = await TokenStorage.getAccessToken();
    final url = Uri.parse('http://10.0.2.2:8080/api/send-mail');

    final body = json.encode({
      "subject": "Обращение в службу поддержки",
      "text": text,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сообщение успешно отправлено')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при отправке: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои покупки')),
      body: FutureBuilder<List<Purchase>>(
        future: _purchasesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Покупок нет'));
          } else {
            final purchases = snapshot.data!;
            return ListView.builder(
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final purchase = purchases[index];
                return ExpansionTile(
                  title: Text('Покупка ${purchase.id}'),
                  subtitle: Text('Товаров: ${purchase.items.length}'),
                  children: [
                    if (purchase.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Покупка пуста'),
                      )
                    else
                      ...purchase.items.map((item) {
                        final product = item.product;
                        return ListTile(
                          leading: Image.network(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            'Цена: ${product.price.toStringAsFixed(2)} руб.\nКоличество: ${item.quantity}',
                          ),
                          isThreeLine: true,
                        );
                      }).toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ElevatedButton(
                        onPressed: _showSupportDialog,
                        child: const Text('Обратиться в поддержку'),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
