import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'profile.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> products;
  late Future<List<Category>> categories;
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceMinController = TextEditingController();
  final TextEditingController priceMaxController = TextEditingController();
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    products = _apiService.fetchProducts();
    categories = _apiService.fetchCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceMinController.dispose();
    priceMaxController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      products = _apiService.fetchProducts(
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
      products = _apiService.fetchProducts();
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

          IconButton(

            icon: const Icon(Icons.account_circle, color: Colors.white),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
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