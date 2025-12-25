import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api.dart';
import 'detailproduk.dart';
import 'dart:async'; // Tambahan untuk Debouncer (opsional, biar tidak spam API)

class ProductListPage extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialSubCategoryId;

  const ProductListPage({
    super.key,
    this.initialCategoryId,
    this.initialSubCategoryId,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // Gunakan ApiService (sesuaikan nama class service Anda)
  final ApiService _apiService = ApiService(); 
  
  late Future<List<dynamic>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce; // Timer untuk jeda pencarian

  // Warna Hijau sesuai screenshot
  final Color _greenColor = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    // Load awal: Gunakan kategori/sub yang dikirim dari Home (jika ada)
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi helper untuk memanggil API
  void _fetchProducts({String query = ''}) {
    setState(() {
      _productsFuture = _apiService.getProducts(
        categoryId: widget.initialCategoryId,       // Filter Kategori (tetap aktif meski mencari nama)
        subCategoryId: widget.initialSubCategoryId, // Filter Sub Kategori
        queryName: query,                           // Filter Nama (Search)
      );
    });
  }

  // Fungsi saat user mengetik di search bar
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Tunggu 500ms setelah user berhenti mengetik baru panggil API
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchProducts(query: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Products",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged, // Panggil fungsi saat mengetik
              decoration: InputDecoration(
                hintText: "Cari Produk...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                filled: true,
                fillColor: const Color(0xFFF5F6F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // --- LIST DATA ---
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: _greenColor),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Produk tidak ditemukan"));
                }

                final products = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    // Data Mapping (Pastikan key JSON sesuai backend)
                    final id = product['product_id']?.toString() ?? '';
                    final name = product['product_name']?.toString() ?? 'No Name';
                    final price = double.tryParse(product['price'].toString()) ?? 0;
                    
                    // Ambil kategori name jika backend sudah mengirimnya
                    final categoryName = product['kategori_name']?.toString() ?? "General";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              productId: id,
                              productName: name,
                              productPrice: price,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            // ICON
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _greenColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.shopping_bag,
                                color: _greenColor,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // TEXT (Nama & Kategori)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    categoryName,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // PRICE
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormatter.format(price),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _greenColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Stock Ready",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}