import 'dart:convert';
import 'package:frontend/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String _base = AppConfig.apiBase;

  static const String _keyUserId = 'auth_user_id';
  static const String _keyUsername = 'auth_username';
  static const String _keyEmail = 'auth_email';

  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 201) {
      throw Exception(body['error'] ?? 'Registration failed.');
    }

    return body;
  }

  static Future<Map<String, dynamic>> login(
      String usernameOrEmail, String password) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? 'Login failed.');
    }

    final prefs = await SharedPreferences.getInstance();
    final user = body['user'] as Map<String, dynamic>;
    await prefs.setInt(_keyUserId, user['user_id'] as int);
    await prefs.setString(_keyUsername, user['username'] as String? ?? '');
    await prefs.setString(_keyEmail, user['email'] as String? ?? '');

    return body;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  static Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyUserId)) return null;

    return {
      'user_id': prefs.getInt(_keyUserId).toString(),
      'username': prefs.getString(_keyUsername) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
    };
  }
}
