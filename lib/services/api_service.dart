import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts({
    String? title,
    double? priceMin,
    double? priceMax,
    int? categoryId,
  }) async {
    String url = '$baseUrl/products';

    if (categoryId != null) {
      url = '$baseUrl/products/category/$categoryId';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      List<Product> products = data.map((e) {
        return Product(
          id: e['id'],
          title: e['title'],
          price: (e['price'] as num).toDouble(),
          description: e['description'],
          images: [e['image']],
          category: null,
        );
      }).toList();

      if (title != null && title.isNotEmpty) {
        products = products
            .where((p) =>
                p.title.toLowerCase().contains(title.toLowerCase()))
            .toList();
      }

      if (priceMin != null) {
        products = products.where((p) => p.price >= priceMin).toList();
      }

      if (priceMax != null) {
        products = products.where((p) => p.price <= priceMax).toList();
      }

      return products;
    } else {
      throw Exception('Error loading products');
    }
  }

  Future<Product> fetchProduct(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
    );

    if (response.statusCode == 200) {
      final e = json.decode(response.body);

      return Product(
        id: e['id'],
        title: e['title'],
        price: (e['price'] as num).toDouble(),
        description: e['description'],
        images: [e['image']],
        category: null,
      );
    } else {
      throw Exception('Error loading product');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/categories'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      return data
          .asMap()
          .entries
          .map((e) => Category(
                id: e.key,
                name: e.value,
                image: '',
              ))
          .toList();
    } else {
      throw Exception('Error loading categories');
    }
  }

  Future<Category> fetchCategory(int id) async {
    final categories = await fetchCategories();
    return categories.firstWhere((c) => c.id == id);
  }

  Future<void> createCategory(String name, String image) async {
    throw Exception('FakeStore API does not support category creation');
  }

  Future<void> updateCategory(int id, String name, String image) async {
    throw Exception('FakeStore API does not support category update');
  }

  Future<void> deleteCategory(int id) async {
    throw Exception('FakeStore API does not support category delete');
  }

  Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    final categories = await fetchCategories();
    final categoryName =
        categories.firstWhere((c) => c.id == categoryId).name;

    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$categoryName'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) {
        return Product(
          id: e['id'],
          title: e['title'],
          price: (e['price'] as num).toDouble(),
          description: e['description'],
          images: [e['image']],
          category: null,
        );
      }).toList();
    } else {
      throw Exception('Error loading products');
    }
  }

  Future<List<User>> fetchUsers() async {
    throw Exception('FakeStore API does not support users');
  }

  Future<User> fetchUser(int id) async {
    throw Exception('FakeStore API does not support users');
  }

  Future<void> createUser(
      String name, String email, String password, String avatar) async {
    throw Exception('FakeStore API does not support users');
  }

  Future<void> updateUser(int id, String name, String email, String avatar) async {
    throw Exception('FakeStore API does not support users');
  }

  Future<void> deleteUser(int id) async {
    throw Exception('FakeStore API does not support users');
  }
}
