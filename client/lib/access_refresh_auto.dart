import 'dart:convert';
import 'package:http/http.dart' as http;
import 'TokenStorage.dart';

class AccessRefreshAuto {
  static const _refreshUrl = 'http://10.0.2.2:8080/api/auth/refresh';

  /// Обновляет access token, используя refresh token из хранилища.
  /// Возвращает true, если обновление прошло успешно, false — если нет.
  static Future<bool> refreshAccessToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      // Нет refresh токена — обновить access токен невозможно
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_refreshUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Обрати внимание: в ответе ключ — "acessToken", возможно опечатка в API?
        // Если это ошибка, нужно согласовать с бекендом.
        // Для надежности можно проверить оба варианта.

        final newAccessToken = data['acessToken'] ?? data['accessToken'];

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await TokenStorage.saveAccessToken(newAccessToken);
          return true;
        } else {
          return false;
        }
      } else {
        // Ошибка на сервере (например, refresh token просрочен)
        return false;
      }
    } catch (e) {
      // Ошибка сети или парсинга
      return false;
    }
  }
}
