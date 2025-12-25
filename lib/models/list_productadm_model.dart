class Product {
  final String productId;
  final String productName;
  final double price;
  final int kategoriId;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.kategoriId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Tanpa Nama',
      // Menggunakan tryParse agar aman jika backend mengirim string/number
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      kategoriId: int.tryParse(json['kategori_id'].toString()) ?? 0,
    );
  }
}