import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ApiService _apiService = ApiService();
  late Future<Product> product;
  bool isEditing = false;

  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    product = _apiService.fetchProduct(widget.productId);
    titleController = TextEditingController();
    priceController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void toggleEditMode(Product product) {
    setState(() {
      if (!isEditing) {
        titleController.text = product.title;
        priceController.text = product.price.toString();
        descriptionController.text = product.description;
      }
      isEditing = !isEditing;
    });
  }

  Future<void> saveChanges() async {
    
    setState(() {
      isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
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

        actions: [
          FutureBuilder<Product>(
            future: product,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return IconButton(

                  icon: Icon(
                    isEditing ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                  
                  onPressed: () => toggleEditMode(snapshot.data!),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),

      body: FutureBuilder<Product>(
        future: product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final productData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    productData.images.isNotEmpty ? productData.images[0] : '',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 100, color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (isEditing)

                  TextField(
                    controller: titleController,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Product Title',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  )

                else
                  Text(
                    productData.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                const SizedBox(height: 16),

                if (isEditing)

                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  )

                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Text(
                      '\$${productData.price}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                  ),

                const SizedBox(height: 24),

                if (productData.category != null) ...[

                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Chip(
                    label: Text(productData.category!.name),
                    avatar: const Icon(Icons.category, size: 18),
                  ),

                  const SizedBox(height: 16),

                ],

                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 8),

                if (isEditing)

                  TextField(
                    controller: descriptionController,
                    maxLines: 6,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                      alignLabelWithHint: true,
                    ),

                  )

                else
                  Text(
                    productData.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),

                const SizedBox(height: 24),

                if (isEditing)

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      
                    ),
                  ),

              ],
            ),
          );
        },
      ),
    );
  }
}