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
