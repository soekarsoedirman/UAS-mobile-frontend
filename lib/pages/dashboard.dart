import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_servis.dart';
import '../services/api.dart'; // Import API Service untuk Logout
import '../pages/statistik.dart';
import '../pages/tambah_produk.dart';
import '../pages/listproductadmin.dart';
import '../pages/login.dart'; // Import Halaman Login

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  late Future<DashboardData> _dashboardFuture;
  final DashboardService _service = DashboardService();

  // Warna tema (Konsisten dengan halaman lain)
  final Color _primaryColor = const Color(0xFF0D1F3C); // Dark Blue
  final Color _accentColor = const Color(0xFF27AE60); // Green
  final Color _softGreenBg = const Color(0xFFEAF9F2); // Light Green Background

  // Formatter uang (Dolar)
  final currencyFormatter = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 1,
  );

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _service.getDashboardData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardFuture = _service.getDashboardData();
    });
  }

  // --- FUNGSI LOGOUT ADMIN ---
  void _handleLogout() async {
    // Panggil fungsi logout dari ApiService (menghapus token lokal)
    await ApiService().logout();

    if (!mounted) return;

    // Arahkan kembali ke Login Page dan hapus semua history route
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background Putih Bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Seller Home",
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade600),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            // --- UBAH DARI CONTAINER BIASA MENJADI POPUP MENU ---
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout();
                }
              },
              offset: const Offset(0, 50),
              // Child ini menjaga tampilan UI tetap sama persis seperti sebelumnya
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, color: _primaryColor),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('Profil Admin'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Keluar', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _accentColor,
        onRefresh: _refreshData,
        child: FutureBuilder<DashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            // 1. Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: _accentColor),
              );
            }

            // 2. Error
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                      ),
                      child: const Text(
                        "Coba Lagi",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            // 3. Success
            if (snapshot.hasData) {
              final data = snapshot.data!;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= PENDAPATAN =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _primaryColor, // Menggunakan Dark Blue
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Pendapatan",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currencyFormatter.format(data.totalRevenue),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32, // Font size sedikit diperbesar
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Update terbaru hari ini",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ================= TOTAL PRODUK & TRANSAKSI =================
                    Row(
                      children: [
                        _smallCard(
                          "Total Produk",
                          data.totalProducts.toString(),
                          Icons.inventory_2_outlined,
                        ),
                        const SizedBox(width: 16),
                        _smallCard(
                          "Total Transaksi",
                          data.totalTransactions.toString(),
                          Icons.receipt_long_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Text(
                      "Menu Utama",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ================= TOMBOL STATISTIK (BARU) =================
                    _dashboardButton(
                      text: "Lihat Laporan Statistik",
                      icon: Icons.bar_chart_rounded,
                      color: _primaryColor, // Dark Blue
                      onTap: () {
                        // Navigasi ke halaman Dashboard Statistik (DashboardPage)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ================= TOMBOL PRODUK (DISABLED) =================
                    _dashboardButton(
                      text: "List Produk",
                      icon: Icons.list_alt_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductListPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _dashboardButton(
                      text: "Tambah Produk",
                      icon: Icons.add_box_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddProductPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text("Tidak ada data"));
          },
        ),
      ),
    );
  }

  // ================= SMALL CARD WIDGET =================
  Widget _smallCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            // Icon dengan background lingkaran hijau muda
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _softGreenBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _accentColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUTTON WIDGET (UPDATED) =================
  Widget _dashboardButton({
    required String text,
    required IconData icon,
    VoidCallback? onTap, // Boleh null untuk disable button
    Color? color,
  }) {
    final backgroundColor = color ?? _primaryColor;
    final isEnabled = onTap != null;

    return SizedBox(
      width: double.infinity,
      height: 56, // Tinggi tombol diperbesar sedikit agar lebih nyaman disentuh
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              Colors.grey[100], // Warna saat disabled lebih terang
          disabledForegroundColor: Colors.grey[400],
          elevation: isEnabled ? 2 : 0,
          shadowColor: backgroundColor.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Radius lebih membulat
          ),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            if (isEnabled)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white70,
              ),
          ],
        ),
      ),
    );
  }
}
