import 'package:flutter/material.dart';
import 'listproduct.dart';
import 'keranjang.dart';
import 'order_list.dart';
import 'login.dart';
import '../services/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  List<dynamic> categories = [];
  List<dynamic> subCategories = [];
  bool isLoading = true;

  // Warna Tema (Konsisten dengan halaman lain)
  final Color _primaryColor = const Color(0xFF0D1F3C); // Dark Blue
  final Color _accentColor = const Color.fromARGB(255, 6, 22, 110);  // Green
  final Color _softGreenBg = const Color(0xFFEAF9F2); // Light Green Background

  @override
  void initState() {
    super.initState();
    fetchHomeData();
  }

  void fetchHomeData() async {
    // Simulasi atau fetch data sebenarnya
    // Jika backend belum siap, ini mungkin error, jadi kita wrap try-catch atau biarkan jika sudah oke
    try {
      final data = await _apiService.getCategories();

      final uniqueCats = <String, dynamic>{};
      for (var item in data) {
        if (item['kategori_id'] != null) {
          uniqueCats[item['kategori_id'].toString()] = {
            'id': item['kategori_id'],
            'name': item['kategori_name'],
          };
        }
      }

      if (mounted) {
        setState(() {
          categories = uniqueCats.values.toList();
          subCategories = data;
          isLoading = false;
        });
      }
    } catch (e) {
      // Fallback jika API gagal (untuk demo UI)
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print("Error fetching home data: $e");
    }
  }

  // --- FUNGSI LOGOUT ---
  void _handleLogout() async {
    await _apiService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Home",
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          // ICON LOGOUT
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: "Keluar",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Konfirmasi"),
                    content: const Text("Apakah Anda yakin ingin keluar?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Batal", style: TextStyle(color: Colors.grey.shade600)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleLogout();
                        },
                        child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: _accentColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Greeting (Optional embellishment)
                  Text(
                    "Temukan Produk\nTerbaik Anda",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// ===== KATEGORI =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kategori",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: _primaryColor
                        ),
                      ),
                      // Text("Lihat Semua", style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (categories.isEmpty)
                    const Text("Belum ada kategori", style: TextStyle(color: Colors.grey)),

                  SizedBox(
                    height: 50, // Tinggi container kategori
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductListPage(
                                  initialCategoryId: cat['id'].toString(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            margin: const EdgeInsets.only(right: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _primaryColor, // Dark Blue pills
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              cat['name'] ?? 'NA',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// ===== SUB KATEGORI =====
                  Text(
                    "Sub Kategori",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: _primaryColor
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (subCategories.isEmpty)
                    const Text("Belum ada sub-kategori", style: TextStyle(color: Colors.grey)),

                  SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: subCategories.length,
                      itemBuilder: (context, index) {
                        final sub = subCategories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductListPage(
                                  initialSubCategoryId: sub['subkategori_id'].toString(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            margin: const EdgeInsets.only(right: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _softGreenBg, // Light Green background
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _accentColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              sub['subkategori_name'] ?? 'NA',
                              style: TextStyle(
                                fontSize: 13,
                                color: _primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// ===== BANNER / PROMO SECTION (Visual Enhancement) =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, const Color(0xFF1E6086)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Jelajahi Semua\nProduk Kami",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Temukan penawaran terbaik hari ini!",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProductListPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: _primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text("Lihat Produk", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.shopping_bag_outlined, 
                          size: 80, 
                          color: Colors.white.withOpacity(0.2)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: _accentColor, // Green active
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), 
              label: "Home"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded),
              label: "Keranjang",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded), 
              label: "Order List"
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellerOrderListPage()),
              );
            }
          },
        ),
      ),
    );
  }
}