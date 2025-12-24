class Product {
  final int? id;
  final String productName;
  final int? price;
  final int subkategoriId;

  Product({
    this.id,
    required this.productName,
    this.price,
    required this.subkategoriId,
  });

  // Untuk menerima data dari API (GET)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'], // Asumsi dari database
      productName: json['product_name'],
      price: json['price'],
      subkategoriId: json['subkategori_id'],
    );
  }

  // Untuk mengirim data ke API (POST/Add Product)
  Map<String, dynamic> toAddJson() {
    return {
      'product_name': productName,
      'price': price,
      'subkategori_id': subkategoriId,
    };
  }

  // Untuk mengirim data ke API (POST/Edit Product {id})

  Map<String, dynamic> toEditJson() {
    return {'product_name': productName, 'subkategori_id': subkategoriId};
  }
}
