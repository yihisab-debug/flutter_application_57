import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';

  Future<List<Product>> fetchProducts({
    String? title,
    double? priceMin,
    double? priceMax,
    int? categoryId,
  }) async {
    String url = '$baseUrl/products?offset=0&limit=20';
    
    if (title != null && title.isNotEmpty) {
      url += '&title=$title';
    }
    if (priceMin != null) {
      url += '&price_min=$priceMin';
    }
    if (priceMax != null) {
      url += '&price_max=$priceMax';
    }
    if (categoryId != null) {
      url += '&categoryId=$categoryId';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Error loading products');
    }
  }

  Future<Product> fetchProduct(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error loading product');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Error loading categories');
    }
  }

  Future<Category> fetchCategory(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$id'),
    );

    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error loading category');
    }
  }

  Future<void> createCategory(String name, String image) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'image': image,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error creating category');
    }
  }

  Future<void> updateCategory(int id, String name, String image) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'image': image,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error updating category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error deleting category');
    }
  }

  Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId/products'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Error loading products');
    }
  }

  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Error loading users');
    }
  }

  Future<User> fetchUser(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$id'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error loading user');
    }
  }

  Future<void> createUser(String name, String email, String password, String avatar) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'avatar': avatar,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error creating user');
    }
  }

  Future<void> updateUser(int id, String name, String email, String avatar) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'avatar': avatar,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error updating user');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error deleting user');
    }
  }
}
