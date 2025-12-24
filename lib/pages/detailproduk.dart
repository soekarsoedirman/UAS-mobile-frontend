import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final String productName;
  final double productPrice;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.productName,
    required this.productPrice,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  bool isLoading = true;
  bool isAddingToCart = false;

  String categoryName = "-";
  String subCategoryName = "-";

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  void fetchDetail() async {
    final data = await ApiService().getProductDetail(widget.productId);
    if (mounted) {
      setState(() {
        if (data != null) {
          categoryName = data['kategori_name']?.toString() ?? "-";
          subCategoryName = data['subkategori_name']?.toString() ?? "-";
        }
        isLoading = false;
      });
    }
  }

  void handleAddToCart() async {
    setState(() => isAddingToCart = true);

    // Panggil API Service
    bool success = await ApiService().addToCart(widget.productId, quantity);

    setState(() => isAddingToCart = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Berhasil menambahkan $quantity ${widget.productName} ke keranjang",
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Opsional: Kembali ke list setelah add
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menambahkan ke keranjang"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text("Detail Produk"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    widget.productName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: isLoading
                      ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          subCategoryName,
                          style: const TextStyle(color: Colors.grey),
                        ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                _infoRow(
                  "Harga Satuan",
                  currencyFormatter.format(widget.productPrice),
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _infoRow("Kategori", isLoading ? "..." : categoryName),
                const SizedBox(height: 8),
                _infoRow("Sub Kategori", isLoading ? "..." : subCategoryName),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Jumlah",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: quantity > 1
                              ? () => setState(() => quantity--)
                              : null,
                        ),
                        Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isAddingToCart ? null : handleAddToCart,
                    child: isAddingToCart
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Tambah ke Keranjang",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
