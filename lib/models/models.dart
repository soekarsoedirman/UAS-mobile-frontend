class User {
  final String username;
  final String role;
  final String token;

  User({required this.username, required this.role, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      role: json['role'] ?? 'customer',
      token: json['token'] ?? '',
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final String price;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? '',
      name: json['product_name'] ?? 'Tiada Nama',
      category: json['kategori_name'],
      subCategory: json['subkategori_name'],
      price: json['price'],
    );
  }
}

class CartItem {
  final int cartId;
  final String productId;
  final String productName;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.productName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'] is int
          ? json['cart_id']
          : int.parse(json['cart_id'].toString()),
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
    );
  }
}
