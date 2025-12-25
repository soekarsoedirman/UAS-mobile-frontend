import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api.dart';

class SellerOrderListPage extends StatefulWidget {
  const SellerOrderListPage({super.key});

  @override
  State<SellerOrderListPage> createState() => _SellerOrderListPageState();
}

class _SellerOrderListPageState extends State<SellerOrderListPage> {
  late Future<List<dynamic>> _ordersFuture;

  // Warna Tema (Konsisten)
  final Color _primaryColor = const Color(0xFF0D1F3C); // Dark Blue
  final Color _accentColor = const Color(0xFF27AE60);  // Green
  final Color _softGreenBg = const Color(0xFFEAF9F2); // Light Green Background
  final Color _softOrangeBg = const Color(0xFFFFF8E1); // Light Orange for Pending

  @override
  void initState() {
    super.initState();
    // Panggil fungsi fetch yang sudah ada sorting-nya
    _ordersFuture = _fetchAndSortOrders();
  }

  // === FUNGSI FETCH & SORT ===
  Future<List<dynamic>> _fetchAndSortOrders() async {
    // 1. Ambil data dari API
    List<dynamic> orders = await ApiService().getOrderHistory();

    // 2. Lakukan Sorting
    orders.sort((a, b) {
      // Fungsi untuk menentukan bobot prioritas
      int getPriority(String? status) {
        String s = (status ?? "").toLowerCase();
        // Prioritas 0 (Paling Atas): Menunggu Konfirmasi / Pending
        if (s.contains('menunggu') || s.contains('pending')) return 0;
        // Prioritas 2 (Paling Bawah): Dikirim / Success
        if (s.contains('dikirim') || s.contains('success')) return 2;
        // Prioritas 1 (Tengah): Status lainnya (misal: Diproses)
        return 1;
      }

      int weightA = getPriority(a["status"]);
      int weightB = getPriority(b["status"]);

      // Bandingkan berdasarkan Status dulu
      if (weightA != weightB) {
        return weightA.compareTo(weightB);
      }

      // Jika status sama, urutkan berdasarkan Tanggal (Terbaru di atas)
      String dateA = a["order_date"] ?? "";
      String dateB = b["order_date"] ?? "";
      return dateB.compareTo(dateA); 
    });

    return orders;
  }
  // ===========================

  Color getStatusColor(String status) {
    if (status == "Dikirim" || status == "Success") {
      return _accentColor;
    } else if (status == "Menunggu Konfirmasi" || status == "Pending") {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  Color getStatusBgColor(String status) {
     if (status == "Dikirim" || status == "Success") {
      return _softGreenBg;
    } else if (status == "Menunggu Konfirmasi" || status == "Pending") {
      return _softOrangeBg;
    } else {
      return Colors.grey.shade100;
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
          "Riwayat Pesanan",
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey.shade600),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _accentColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_rounded, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("Belum ada riwayat pesanan", style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              final productName = order["product_name"] ?? "Unknown";
              final status = order["status"] ?? "-";
              final sales = double.tryParse(order["sales"].toString()) ?? 0;
              final qty = order["quantity"] ?? 0;
              final shipMode = order["shipmode"] ?? "-";

              // Format tanggal
              String dateStr = order["order_date"] ?? "-";
              try {
                DateTime dt = DateTime.parse(dateStr);
                dateStr = DateFormat('dd MMM yyyy').format(dt);
              } catch (e) {
                // ignore
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _softGreenBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: _accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // TEXT CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$dateStr • $shipMode",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Status Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusBgColor(status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: getStatusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // PRICE & QTY
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormatter.format(sales),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Qty: $qty",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}