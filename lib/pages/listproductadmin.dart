import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/list_productadm_model.dart';
import '../services/listproduct_adm.dart';
import '../pages/detailproduk_adm.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<Product> _products = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true; // Penanda apakah masih ada data di halaman berikutnya
  String _searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    // Listener untuk mendeteksi scroll mentok bawah (Pagination)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi mengambil data dari Service
  Future<void> _fetchProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newProducts = await _productService.getProducts(
        page: _currentPage,
        queryName: _searchQuery,
      );

      setState(() {
        _currentPage++;

        // Jika data yang diterima kurang dari 10, anggap sudah halaman terakhir
        if (newProducts.length < 10) {
          _hasMore = false;
        }

        _products.addAll(newProducts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat: $e')));
      }
    }
  }

  // Fungsi Pencarian dengan Debounce
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _products.clear(); // Hapus list lama
        _currentPage = 1; // Reset halaman ke 1
        _hasMore = true;
      });
      _fetchProducts(); // Panggil API lagi dengan nama baru
    });
  }

  // Fungsi Refresh (Tarik Layar)
  Future<void> _refreshList() async {
    setState(() {
      _products.clear();
      _currentPage = 1;
      _hasMore = true;
      _searchController.clear();
      _searchQuery = "";
    });
    await _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 1,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF7),
      appBar: AppBar(
        title: const Text(
          "List Produk",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // ================= SEARCH BAR =================
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Cari nama produk...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================= LIST PRODUK =================
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshList,
              color: Colors.green,
              child: _products.isEmpty && !_isLoading
                  ? const Center(child: Text("Produk tidak ditemukan"))
                  : ListView.builder(
                      controller: _scrollController,
                      // +1 item untuk loading spinner di bawah
                      itemCount: _products.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Tampilkan Loading di item paling bawah
                        if (index == _products.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: Colors.green,
                              ),
                            ),
                          );
                        }

                        final product = _products[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.green,
                              ),
                            ),
                            title: Text(
                              product.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Kategori: ${product.kategoriId}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              currencyFormatter.format(product.price),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(
                                    productId: product.productId,
                                    productName: product.productName,
                                    productPrice: product.price,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
