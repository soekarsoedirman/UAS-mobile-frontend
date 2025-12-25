import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/orderlist_adm_model.dart';
import '../services/order_adm.dart'; 
import '../pages/orderdetail.dart';

class SellerOrderListPage extends StatefulWidget {
  const SellerOrderListPage({super.key});

  @override
  State<SellerOrderListPage> createState() => _SellerOrderListPageState();
}

class _SellerOrderListPageState extends State<SellerOrderListPage> {
  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;

  // Warna Tema
  final Color _greenColor = const Color(0xFF0D1F3C);
  final Color _bgSoftGreen = const Color(0xFFE8F5E9); 

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // === MODIFIKASI SORTING DISINI ===
  Future<void> _refreshData() async {
    setState(() {
      // Kita ambil datanya, lalu kita sort manual sebelum dimasukkan ke _ordersFuture
      _ordersFuture = _orderService.getOrderList().then((orders) {
        
        orders.sort((a, b) {
          // Fungsi Helper untuk memberi bobot status
          int getStatusWeight(String status) {
            String s = status.toLowerCase();
            if (s.contains('menunggu')) return 0; // Prioritas Utama (Paling Atas)
            if (s.contains('dikirim') || s.contains('success')) return 2; // Paling Bawah
            return 1; // Status lain di tengah
          }

          int weightA = getStatusWeight(a.status);
          int weightB = getStatusWeight(b.status);

          // Bandingkan bobot
          // Jika bobot sama, kita bisa urutkan berdasarkan tanggal (opsional)
          if (weightA != weightB) {
            return weightA.compareTo(weightB); 
          } else {
             // Jika status sama, urutkan tanggal terbaru di atas (descending)
             // Pastikan orderDate formatnya bisa dibandingkan stringnya (ISO) atau parse dulu
             return b.orderDate.compareTo(a.orderDate);
          }
        });

        return orders;
      });
    });
  }
  // =================================

  @override
  Widget build(BuildContext context) {
    // Formatter Uang
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$', 
      decimalDigits: 2,
    );

    // Formatter Tanggal
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB), 
      appBar: AppBar(
        title: const Text(
          "Daftar Pesanan Masuk",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _greenColor));
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 10),
                    Text(
                      "Terjadi Kesalahan:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshData,
                      style: ElevatedButton.styleFrom(backgroundColor: _greenColor),
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              ),
            );
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada pesanan masuk."));
          }

          final orders = snapshot.data!;

          // 4. List Data
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              
              DateTime? parsedDate;
              try {
                parsedDate = DateTime.parse(order.orderDate);
              } catch (_) {}

              return GestureDetector(
                onTap: () {
                  // --- NAVIGASI KE DETAIL ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(orderId: order.orderId),
                    ),
                  ).then((_) {
                    // Refresh data saat kembali dari detail (agar status terupdate di list)
                    _refreshData();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- ICON KIRI ---
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _bgSoftGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: _greenColor,
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(width: 16),

                      // --- INFORMASI TENGAH ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName, 
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Order ID: ${order.orderId.length > 8 ? order.orderId.substring(0, 8) : order.orderId}...", 
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Status & Tanggal
                            Row(
                              children: [
                                _buildStatusBadge(order.status),
                                const SizedBox(width: 8),
                                Text(
                                  parsedDate != null 
                                    ? dateFormatter.format(parsedDate) 
                                    : order.orderDate,
                                  style: TextStyle(
                                    fontSize: 11, 
                                    color: Colors.grey.shade400
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      // --- HARGA KANAN ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(order.sales),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _greenColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${order.quantity} Items",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
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
    );
  }

  // Helper Widget untuk Status Badge Kecil
  Widget _buildStatusBadge(String status) {
    Color bgColor = Colors.blue.shade50;
    Color textColor = Colors.blue;

    if (status.toLowerCase().contains('dikirim') || status.toLowerCase().contains('success')) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green;
    } else if (status.toLowerCase().contains('menunggu')) {
      bgColor = Colors.orange.shade50; // Menunggu konfirmasi warna oranye
      textColor = Colors.orange;
    } else if (status.toLowerCase().contains('cancel')) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}