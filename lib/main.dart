import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      home: const MainNavigationPage(),
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

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    users = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/users'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Error loading users');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('https://api.escuelajs.co/api/v1/users/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        users = fetchUsers();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting user')),
        );
      }
    }
  }

  void showCreateUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final avatarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Create User', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: avatarController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  hintText: 'https://placehold.co/400x400',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
              ),

            ],
          ),
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && 
                  emailController.text.isNotEmpty && 
                  passwordController.text.isNotEmpty) {
                await createUser(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                  avatarController.text.isNotEmpty 
                    ? avatarController.text 
                    : 'https://placehold.co/400x400',
                );

                if (mounted) {
                  Navigator.pop(context);
                }

              }
            },

            child: const Text('Create'),
          ),

        ],
      ),
    );
  }

  Future<void> createUser(String name, String email, String password, String avatar) async {
    final response = await http.post(
      Uri.parse('https://api.escuelajs.co/api/v1/users/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'avatar': avatar,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        users = fetchUsers();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Users'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey,
        actions: [

          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: showCreateUserDialog,
          ),

        ],
      ),

      body: FutureBuilder<List<User>>(
        future: users,
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
                'No users found',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final user = items[index];

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      user.avatar ?? 'https://placehold.co/400x400',
                    ),
                    onBackgroundImageError: (_, __) {},
                    child: user.avatar == null 
                      ? const Icon(Icons.person, size: 30, color: Colors.white) 
                      : null,
                  ),

                  title: Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Role: ${user.role}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailPage(
                                userId: user.id,
                                onUpdate: () {
                                  setState(() {
                                    users = fetchUsers();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],

                              title: const Text(
                                'Delete User',
                                style: TextStyle(color: Colors.white),
                              ),

                              content: Text(
                                'Are you sure you want to delete "${user.name}"?',
                                style: const TextStyle(color: Colors.white70),
                              ),

                              actions: [

                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                ),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    deleteUser(user.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                ),

                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailPage(
                          userId: user.id,
                          onUpdate: () {
                            setState(() {
                              users = fetchUsers();
                            });
                          },
                        ),
                      ),
                    );
                  },

                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  final int userId;
  final VoidCallback onUpdate;

  const UserDetailPage({
    super.key,
    required this.userId,
    required this.onUpdate,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late Future<User> user;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController avatarController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    user = fetchUser();
    nameController = TextEditingController();
    emailController = TextEditingController();
    avatarController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  Future<User> fetchUser() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/users/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final userData = User.fromJson(json.decode(response.body));
      nameController.text = userData.name;
      emailController.text = userData.email;
      avatarController.text = userData.avatar ?? '';
      return userData;
    } else {
      throw Exception('Error loading user');
    }
  }

  Future<void> updateUser() async {
    final response = await http.put(
      Uri.parse('https://api.escuelajs.co/api/v1/users/${widget.userId}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'email': emailController.text,
        'avatar': avatarController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        user = fetchUser();
        isEditing = false;
      });
      widget.onUpdate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(

        title: const Text('User Details'),

        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),

        backgroundColor: Colors.grey,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [

          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),

        ],
      ),

      body: FutureBuilder<User>(
        future: user,
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

          final usr = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Center(
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(
                      usr.avatar ?? 'https://placehold.co/400x400',
                    ),
                    onBackgroundImageError: (_, __) {},
                    child: usr.avatar == null 
                      ? const Icon(Icons.person, size: 80, color: Colors.white) 
                      : null,
                  ),
                ),

                const SizedBox(height: 24),
                
                if (isEditing) ...[

                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: avatarController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Avatar URL',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updateUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),

                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                    ),
                  ),

                ] else ...[
                  const Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usr.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usr.email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Role',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usr.role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'ID',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usr.id.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  late Future<List<Category>> categories;

  @override
  void initState() {
    super.initState();
    categories = fetchCategories();
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

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('https://api.escuelajs.co/api/v1/categories/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        categories = fetchCategories();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting category')),
        );
      }
    }
  }

  void showCreateCategoryDialog() {
    final nameController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Create Category', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: imageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Image URL',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                hintText: 'https://placehold.co/600x400',
                hintStyle: TextStyle(color: Colors.white30),
              ),
            ),

          ],
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await createCategory(
                  nameController.text,
                  imageController.text.isNotEmpty 
                    ? imageController.text 
                    : 'https://placehold.co/600x400',
                );

                if (mounted) {
                  Navigator.pop(context);
                }

              }
            },

            child: const Text('Create'),
          ),

        ],
      ),
    );
  }

  Future<void> createCategory(String name, String image) async {
    final response = await http.post(
      Uri.parse('https://api.escuelajs.co/api/v1/categories/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'image': image,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        categories = fetchCategories();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating category')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Categories'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey,
        actions: [

          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: showCreateCategoryDialog,
          ),

        ],
      ),

      body: FutureBuilder<List<Category>>(
        future: categories,
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
                'No categories found',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final category = items[index];

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: ClipRRect(

                    borderRadius: BorderRadius.circular(8),

                    child: Image.network(
                      category.image ?? 'https://placehold.co/600x400',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.category, size: 60, color: Colors.white),
                    ),

                  ),

                  title: Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    'ID: ${category.id} • Slug: ${category.slug ?? "N/A"}',
                    style: const TextStyle(color: Colors.white70),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryDetailPage(
                                categoryId: category.id,
                                onUpdate: () {
                                  setState(() {
                                    categories = fetchCategories();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],

                              title: const Text(
                                'Delete Category',
                                style: TextStyle(color: Colors.white),
                              ),

                              content: Text(
                                'Are you sure you want to delete "${category.name}"?',
                                style: const TextStyle(color: Colors.white70),
                              ),

                              actions: [

                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                ),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    deleteCategory(category.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                ),

                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryProductsPage(
                          categoryId: category.id,
                          categoryName: category.name,
                        ),
                      ),
                    );
                  },

                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryDetailPage extends StatefulWidget {
  final int categoryId;
  final VoidCallback onUpdate;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.onUpdate,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late Future<Category> category;
  late TextEditingController nameController;
  late TextEditingController imageController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    category = fetchCategory();
    nameController = TextEditingController();
    imageController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<Category> fetchCategory() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/categories/${widget.categoryId}'),
    );

    if (response.statusCode == 200) {
      final categoryData = Category.fromJson(json.decode(response.body));
      nameController.text = categoryData.name;
      imageController.text = categoryData.image ?? '';
      return categoryData;
    } else {
      throw Exception('Error loading category');
    }
  }

  Future<void> updateCategory() async {
    final response = await http.put(
      Uri.parse('https://api.escuelajs.co/api/v1/categories/${widget.categoryId}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'image': imageController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        category = fetchCategory();
        isEditing = false;
      });
      widget.onUpdate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating category')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(

        title: const Text('Category Details'),

        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),

        backgroundColor: Colors.grey,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [

          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),

        ],
      ),

      body: FutureBuilder<Category>(
        future: category,
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

          final cat = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),

                    child: Image.network(
                      cat.image ?? 'https://placehold.co/600x400',
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.category, size: 100, color: Colors.white),
                    ),

                  ),
                ),

                const SizedBox(height: 24),
                
                if (isEditing) ...[

                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: imageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updateCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),

                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                    ),
                  ),

                ] else ...[
                  const Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    cat.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Slug',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    cat.slug ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'ID',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    cat.id.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoryProductsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    products = fetchProductsByCategory();
  }

  Future<List<Product>> fetchProductsByCategory() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/categories/${widget.categoryId}/products'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Error loading products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(

        title: Text(widget.categoryName),

        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),

        backgroundColor: Colors.grey,
        iconTheme: const IconThemeData(color: Colors.white),

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
                'No products in this category',
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