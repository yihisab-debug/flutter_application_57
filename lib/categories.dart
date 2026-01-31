import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

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

          const ProfileButton(),

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