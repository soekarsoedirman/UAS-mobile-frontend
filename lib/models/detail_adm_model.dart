class ProductDetail {
  final String productId;
  final String productName;
  final double price;
  final String subCategoryName;
  final String categoryName;

  ProductDetail({
    required this.productId,
    required this.productName,
    required this.price,
    required this.subCategoryName,
    required this.categoryName,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Tanpa Nama',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      subCategoryName: json['subkategori_name']?.toString() ?? '-',
      categoryName: json['kategori_name']?.toString() ?? '-',
    );
  }
}