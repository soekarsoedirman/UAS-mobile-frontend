import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_servis.dart';
import '../pages/statistik.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  late Future<DashboardData> _dashboardFuture;
  final DashboardService _service = DashboardService();

  final Color _primaryColor = const Color(0xFF0D1F3C);
  final Color _accentColor = const Color(0xFF27AE60);
  final Color _softGreenBg = const Color(0xFFEAF9F2);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dashboardFuture = _service.getDashboardData();
    });
  }

  Future<void> _refreshData() async {
    _loadData();
    await _dashboardFuture; // Tunggu selesai
  }

  @override
  Widget build(BuildContext context) {
    // Formatter Rupiah
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
        title: Text(
          "Seller Home",
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade600),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline, color: _primaryColor),
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
                      "Gagal memuat data.\nPastikan Anda login sebagai Admin.",
                      textAlign: TextAlign.center,
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
                        color: _primaryColor,
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
                            currencyFormatter.format(
                              data.totalRevenue,
                            ), // Pakai formatter
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28, // Sedikit disesuaikan agar muat
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Total pendapatan dari seluruh transaksi",
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

                    // ================= TOMBOL STATISTIK =================
                    _dashboardButton(
                      text: "Lihat Laporan Statistik",
                      icon: Icons.bar_chart_rounded,
                      color: _primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ================= TOMBOL PRODUK (Navigasi ke ListProduct umum dulu) =================
                    _dashboardButton(
                      text: "Tambah Produk Baru",
                      icon: Icons.add_box_rounded,
                      color: _accentColor,
                      onTap: () async {
                        // Import halaman tambah produk di header jika ingin dipakai: import 'tambah_produk.dart';
                        Navigator.pushNamed(
                          context,
                          '/tambah_produk',
                        ); // Atau gunakan MaterialPageRoute
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

  Widget _dashboardButton({
    required String text,
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
  }) {
    final backgroundColor = color ?? _primaryColor;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: backgroundColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
