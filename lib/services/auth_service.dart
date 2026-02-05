import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class AuthService {
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';
  static User? currentUser;
  static String? accessToken;
  static String? refreshToken;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final refresh = prefs.getString(_refreshTokenKey);
    final userData = prefs.getString(_userKey);

    if (token != null && userData != null) {
      accessToken = token;
      refreshToken = refresh;
      currentUser = User.fromJson(json.decode(userData));

      try {
        final response = await http.get(
          Uri.parse('$baseUrl/auth/profile'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          currentUser = User.fromJson(json.decode(response.body));
          await _saveUserData(currentUser!);
          return true;
        } else if (refresh != null) {

          return await _refreshAccessToken();
        } else {
          await _clearSession();
          return false;
        }
      } catch (e) {

        return true;
      }
    }
    return false;
  }


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
        accessToken = data['access_token'];
        refreshToken = data['refresh_token'];

        final profileResponse = await http.get(
          Uri.parse('$baseUrl/auth/profile'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (profileResponse.statusCode == 200) {
          currentUser = User.fromJson(json.decode(profileResponse.body));
          await _saveSession();
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
          'avatar': avatar.isNotEmpty ? avatar : 'https://picsum.photos/800',
        }),
      );

      if (response.statusCode == 201) {

        return await login(email, password);
      }
      return false;
    } catch (e) {
      return false;
    }
  }


  Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/is-available'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isAvailable'] == true;
      }
      return false;
    } catch (e) {
      return true;
    }
  }


  Future<bool> updateUser({String? name, String? email, String? avatar}) async {
    if (currentUser == null || accessToken == null) return false;

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (avatar != null) body['avatar'] = avatar;

      final response = await http.put(
        Uri.parse('$baseUrl/users/${currentUser!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        currentUser = User.fromJson(json.decode(response.body));
        await _saveUserData(currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }


  Future<bool> _refreshAccessToken() async {
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        accessToken = data['access_token'];
        refreshToken = data['refresh_token'];
        await _saveSession();

        final profileResponse = await http.get(
          Uri.parse('$baseUrl/auth/profile'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (profileResponse.statusCode == 200) {
          currentUser = User.fromJson(json.decode(profileResponse.body));
          await _saveUserData(currentUser!);
          return true;
        }
      }
      await _clearSession();
      return false;
    } catch (e) {
      return false;
    }
  }


  Future<void> logout() async {
    await _clearSession();
  }

  bool isLoggedIn() {
    return currentUser != null && accessToken != null;
  }


  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      await prefs.setString(_accessTokenKey, accessToken!);
    }
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken!);
    }
    if (currentUser != null) {
      await _saveUserData(currentUser!);
    }
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    currentUser = null;
    accessToken = null;
    refreshToken = null;
  }
}