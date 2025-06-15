import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import 'TokenStorage.dart';
import 'app.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  Future<void> _showPaymentDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Оплатить?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Да'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _processPayment(context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ShoppingApp()),
      );
    }
  }

  Future<void> _processPayment(BuildContext context) async {
    try {
      final token = await TokenStorage.getAccessToken();

      final paymentUrl = Uri.parse('http://10.0.2.2:8080/api/payment/create');
      final response = await http.post(
        paymentUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paymentLink = data['url'];

        if (paymentLink != null && Uri.tryParse(paymentLink) != null) {
          _showLinkDialog(context, paymentLink);
        } else {
          _showError(context, 'Не удалось получить ссылку оплаты');
        }
      } else {
        _showError(context, 'Ошибка при создании платежа');
      }
    } catch (e) {
      _showError(context, 'Ошибка: $e');
    }
  }

  Future<bool> _createPurchaseFromCart(BuildContext context) async {
    try {
      final token = await TokenStorage.getAccessToken();

      final purchaseUrl = Uri.parse('http://10.0.2.2:8080/api/purchases/create-from-cart');
      final purchaseResponse = await http.post(
        purchaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (purchaseResponse.statusCode == 200) {
        return true;
      } else {
        _showError(context, 'Ошибка при создании покупки из корзины');
        return false;
      }
    } catch (e) {
      _showError(context, 'Ошибка: $e');
      return false;
    }
  }
  void _showLinkDialog(BuildContext context, String paymentUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ссылка на оплату'),
          content: SelectableText(paymentUrl),
          actions: [
            TextButton(
            onPressed: () async {
              // Копируем в буфер обмена
              await Clipboard.setData(ClipboardData(text: paymentUrl));

              // Показываем SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ссылка скопирована в буфер обмена')),
              );

              // Закрываем диалог
              Navigator.of(context).pop();
               _createPurchaseFromCart(context);

              // Переходим на ShoppingApp
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ShoppingApp()),
              );
}
,
              child: const Text('Копировать'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }



  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Доставка')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Имя получателя'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите телефон' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Адрес доставки'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите адрес' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {

                    _showPaymentDialog(context);
                  }
                },
                child: const Text('Перейти к оплате'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
