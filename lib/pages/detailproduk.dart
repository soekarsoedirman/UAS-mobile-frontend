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
  final Color _greenColor = const Color(0xFF4CAF50);

  // Variabel data detail
  String categoryName = "-";
  String subCategoryName = "-";

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  void fetchDetail() async {
    // Mengambil data detail (Kategori & Sub Kategori) dari backend
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
    bool success = await ApiService().addToCart(widget.productId, quantity);
    setState(() => isAddingToCart = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil menambahkan $quantity items"),
          backgroundColor: _greenColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menambahkan"),
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
      backgroundColor:
          Colors.grey[50], // Background agak abu sedikit agar card terlihat
      appBar: AppBar(
        title: const Text(
          "Detail Produk",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // --- ICON BESAR ---
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: _greenColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_bag, size: 40, color: _greenColor),
              ),

              const SizedBox(height: 16),

              // --- NAMA PRODUK ---
              Text(
                widget.productName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              // --- KATEGORI SUBTITLE ---
              Text(
                isLoading ? "Loading..." : categoryName,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),

              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade200, thickness: 1),
              const SizedBox(height: 24),

              // --- RINCIAN HARGA & KATEGORI ---
              _detailRow(
                "Harga Satuan",
                currencyFormatter.format(widget.productPrice),
                _greenColor,
              ),
              const SizedBox(height: 12),
              _detailRow(
                "Kategori",
                isLoading ? "..." : categoryName,
                Colors.black87,
              ),
              const SizedBox(height: 12),
              _detailRow(
                "Sub Kategori",
                isLoading ? "..." : subCategoryName,
                Colors.black87,
              ),

              const SizedBox(height: 30),

              // --- JUMLAH (QUANTITY) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Jumlah",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      _qtyButton(Icons.remove, () {
                        if (quantity > 1) setState(() => quantity--);
                      }),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "$quantity",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _qtyButton(Icons.add, () {
                        setState(() => quantity++);
                      }),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- TOMBOL ADD TO CART ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isAddingToCart ? null : handleAddToCart,
                  child: isAddingToCart
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
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
    );
  }

  // Widget Helper untuk Baris Detail
  Widget _detailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Widget Helper untuk Tombol Qty (+ / -)
  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
    );
  }
}
