import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TokenStorage.dart';
import 'access_refresh_auto.dart';
import 'app.dart';
import 'purchases_page.dart'; // ✅ добавлен импорт

class User {
  final String email;
  final DateTime createdAt;

  User({required this.email, required this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      String? token = await TokenStorage.getAccessToken();

      if (token == null) {
        setState(() {
          _error = 'Вы не авторизованы.';
          _loading = false;
        });
        return;
      }

      http.Response response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        bool refreshed = await AccessRefreshAuto.refreshAccessToken();
        if (refreshed) {
          token = await TokenStorage.getAccessToken();
          response = await http.get(
            Uri.parse('http://10.0.2.2:8080/api/me'),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _user = User.fromJson(jsonData);
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        await TokenStorage.clearTokens();
        setState(() {
          _error = 'Сессия истекла. Пожалуйста, войдите снова.';
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Ошибка: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка при загрузке профиля: $e';
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clearTokens();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ShoppingApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text("Назад ко входу"),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email: ${_user!.email}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                "Создан: ${_user!.createdAt.toLocal().toString().split('.').first}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PurchasesPage()),
                  );
                },
                child: const Text("Посмотреть историю покупок"),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _logout,
                  child: const Text("Выйти"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
