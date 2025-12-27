import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/detail_adm.dart';
import '../models/detail_adm_model.dart';
import '../pages/editproduk.dart';

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
  final ProductService _service = ProductService();

  bool isLoading = true;
  bool isDeleting = false;
  ProductDetail? _detail;

  // Warna tema
  final Color _primaryColor = const Color(0xFF0D1F3C);
  final Color _accentColor = const Color(0xFF27AE60);
  final Color _softGreenBg = const Color(0xFFEAF9F2);
  final Color _softRedBg = const Color(0xFFFFEBEE);

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() async {
    try {
      final data = await _service.getProductDetail(widget.productId);
      if (mounted) {
        setState(() {
          _detail = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }

  void _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isDeleting = true);

    try {
      await _service.deleteProduct(widget.productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produk berhasil dihapus"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Detail Produk",
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey.shade600),
        elevation: 0,
      ),
      body: isDeleting
          ? Center(child: CircularProgressIndicator(color: _accentColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON IMAGE
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _softGreenBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 48,
                        color: _accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // NAMA PRODUK
                  Center(
                    child: Text(
                      _detail?.productName ?? widget.productName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // SUB KATEGORI
                  Center(
                    child: isLoading
                        ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(
                      _detail?.subCategoryName ?? "Sub-Kategori",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TOMBOL EDIT & HAPUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProductPage(
                                productId: widget.productId,
                                currentName: _detail?.productName ?? widget.productName,
                                currentPrice: _detail?.price ?? widget.productPrice,
                              ),
                            ),
                          );
                          if (result == true) {
                            _fetchDetail();
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _softGreenBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.edit_outlined, color: _accentColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: _deleteProduct,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _softRedBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(height: 1),
                  const SizedBox(height: 24),

                  Text(
                    "Informasi Detail",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _infoRow("Harga Satuan", currencyFormatter.format(_detail?.price ?? widget.productPrice), _accentColor),
                  const SizedBox(height: 12),
                  _infoRow("Kategori", isLoading ? "Loading..." : (_detail?.categoryName ?? "-")),
                  const SizedBox(height: 12),
                  _infoRow("Sub Kategori", isLoading ? "Loading..." : (_detail?.subCategoryName ?? "-")),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper row biasa untuk data pendek
  Widget _infoRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        // Flexible agar teks kanan tidak overflow jika agak panjang (tapi tetap satu baris)
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? _primaryColor,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}