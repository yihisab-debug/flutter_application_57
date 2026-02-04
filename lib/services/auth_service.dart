import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class AuthService {
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';
  static User? currentUser;
  static String? authToken;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        authToken = data['access_token'];
        
        final profileResponse = await http.get(
          Uri.parse('$baseUrl/auth/profile'),
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        );

        if (profileResponse.statusCode == 200) {
          currentUser = User.fromJson(json.decode(profileResponse.body));
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String avatar) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'avatar': avatar.isNotEmpty ? avatar : 'https://placehold.co/400x400',
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    currentUser = null;
    authToken = null;
  }

  bool isLoggedIn() {
    return currentUser != null && authToken != null;
  }
}
