import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'categories.dart';
import 'users.dart';
import 'login.dart';
import 'profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Platzi Store',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.dark,
      ),
      home: const LoginPage(),
    );
  }
}

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final List images;
  final Category? category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      images: json['images'],
      category: json['category'] != null 
          ? Category.fromJson(json['category']) 
          : null,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? slug;
  final String? image;

  Category({
    required this.id, 
    required this.name, 
    this.slug, 
    this.image
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image ?? 'https://placehold.co/600x400',
    };
  }
}

class User {
  final int id;
  final String email;
  final String password;
  final String name;
  final String role;
  final String? avatar;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      role: json['role'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'avatar': avatar ?? 'https://placehold.co/400x400',
    };
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ProductListPage(),
    const CategoryManagementPage(),
    const UserManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],

      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.account_circle, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      },
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> products;
  late Future<List<Category>> categories;
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceMinController = TextEditingController();
  final TextEditingController priceMaxController = TextEditingController();
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    products = fetchProducts();
    categories = fetchCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceMinController.dispose();
    priceMaxController.dispose();
    super.dispose();
  }

  Future<List<Product>> fetchProducts({
    String? title,
    double? priceMin,
    double? priceMax,
    int? categoryId,
  }) async {
    String url = 'https://api.escuelajs.co/api/v1/products?offset=0&limit=20';
    
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

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/categories'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Error loading categories');
    }
  }

  void applyFilters() {
    setState(() {
      products = fetchProducts(
        title: titleController.text.isNotEmpty ? titleController.text : null,
        priceMin: priceMinController.text.isNotEmpty 
            ? double.tryParse(priceMinController.text) 
            : null,
        priceMax: priceMaxController.text.isNotEmpty 
            ? double.tryParse(priceMaxController.text) 
            : null,
        categoryId: selectedCategoryId,
      );
    });
  }

  void resetFilters() {
    setState(() {
      titleController.clear();
      priceMinController.clear();
      priceMaxController.clear();
      selectedCategoryId = null;
      products = fetchProducts();
    });
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) => Padding(

        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),

              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Search by title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: priceMinController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Min Price',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: '0',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                      prefixStyle: TextStyle(color: Colors.white)
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: TextField(
                    controller: priceMaxController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Max Price',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: '1000',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                      prefixStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 16),
            
            FutureBuilder<List<Category>>(
              future: categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text('Error loading categories');
                }
                
                final categoryList = snapshot.data ?? [];
                
                return DropdownButtonFormField<int>(
                  dropdownColor: Colors.black,
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category, color: Colors.white),
                  ),

                  hint: const Text('Select a category'),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text(
                        'All Categories', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    ...categoryList.map((category) => DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        category.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),

                  ],

                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },

                );
              },
            ),

            const SizedBox(height: 24),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      resetFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reset', style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply'),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Products'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey,
        actions: [

          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: showFilterBottomSheet,
          ),

          const ProfileButton(),

        ],
      ),

      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No products found',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.65,
            ),

            itemBuilder: (context, index) {
              final product = items[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(productId: product.id),
                    ),
                  );
                },

                child: Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          product.images.isNotEmpty ? product.images[0] : '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 50),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '\$${product.price}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  Future<Product> fetchProduct() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/products/$productId'),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error loading product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Detail'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),

        backgroundColor: Colors.grey,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: FutureBuilder<Product>(
        future: fetchProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final product = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Image.network(
                  product.images.isNotEmpty ? product.images[0] : '',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, size: 100),
                ),

                const SizedBox(height: 16),

                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 16),

                Text(product.description),

              ],
            ),
          );
        },
      ),
    );
  }
}