import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api.dart';
import 'listproduct.dart';
import 'tambah_produk.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  // Variabel Data
  int totalProduk = 0;
  int totalTransaksi = 0;
  double totalPendapatan = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final response = await ApiService().getDashboard();
      if (response['status'] == 'success') {
        final metrics = response['data']['metrics'];
        setState(() {
          totalProduk = metrics['total_products'] ?? 0;
          totalTransaksi = metrics['total_transactions'] ?? 0;
          totalPendapatan =
              double.tryParse(metrics['total_revenue'].toString()) ?? 0.0;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
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
      backgroundColor: const Color.fromARGB(255, 246, 251, 247),
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: Colors.green,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD PENDAPATAN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Pendapatan",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currencyFormatter.format(totalPendapatan),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _smallCard("Total Produk", totalProduk.toString()),
                      const SizedBox(width: 12),
                      _smallCard("Total Transaksi", totalTransaksi.toString()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _dashboardButton(
                    "List Produk",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductListPage()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dashboardButton("Tambah Produk", () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddProductPage()),
                    );
                    fetchData(); // Refresh data setelah tambah produk
                  }),
                ],
              ),
            ),
    );
  }

  Widget _smallCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
