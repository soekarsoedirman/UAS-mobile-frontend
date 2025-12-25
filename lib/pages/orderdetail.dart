import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/orderdetail_model.dart';
import '../services/order_adm.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderService _service = OrderService();
  late Future<List<OrderDetailModel>> _detailFuture;
  
  bool isConfirming = false;
  String currentStatus = "";

  final Color _greenColor = const Color(0xFF0D1F3C);
  final Color _bgSoft = const Color(0xFFF6F8FB);

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.getOrderDetail(widget.orderId);
  }

  // --- FUNGSI FORMAT TANGGAL (BARU) ---
  String _formatDate(String dateString) {
    try {
      // Parsing string ISO 8601 menjadi DateTime object
      DateTime parsedDate = DateTime.parse(dateString);
      // Mengubah format menjadi yyyy/MM/dd
      return DateFormat('yyyy/MM/dd').format(parsedDate);
    } catch (e) {
      // Jika format salah/error, kembalikan string aslinya
      return dateString;
    }
  }

  Future<void> _handleConfirm() async {
    setState(() => isConfirming = true);

    bool success = await _service.confirmOrder(widget.orderId);

    if (!mounted) return;

    setState(() => isConfirming = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pesanan berhasil dikonfirmasi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengkonfirmasi pesanan."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US', symbol: '\$', decimalDigits: 2
    );

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<OrderDetailModel>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _greenColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final items = snapshot.data!;
          final headerInfo = items.first; 
          
          final double grandTotal = items.fold(0, (sum, item) => sum + item.sales);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // INFO ORDER
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            _infoRow("Order ID", "#${widget.orderId.substring(0, 8)}..."),
                            const Divider(height: 24),
                            _infoRow("Pelanggan", headerInfo.customerName),
                            const SizedBox(height: 8),
                            
                            // --- PEMANGGILAN FUNGSI FORMAT TANGGAL ---
                            _infoRow("Tanggal", _formatDate(headerInfo.orderDate)), 
                            
                            const SizedBox(height: 8),
                            _infoRow("Kode Pos", headerInfo.postalCode),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Text("Daftar Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),

                      // LIST PRODUK
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _greenColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.inventory_2, color: _greenColor, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text("${item.quantity} x Item", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(currencyFormatter.format(item.sales), style: TextStyle(fontWeight: FontWeight.bold, color: _greenColor)),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // TOMBOL CONFIRM
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(currencyFormatter.format(grandTotal), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _greenColor)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _greenColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isConfirming ? null : _handleConfirm,
                          child: isConfirming
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Konfirmasi Pesanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}