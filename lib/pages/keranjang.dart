import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api.dart'; // Import API Service

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  List<dynamic> cartItems = [];

  // Controller untuk input alamat
  final postalCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final regionCtrl = TextEditingController();
  // Shipmode ID sederhana (misal: 1=Standard, 2=Express)
  final shipModeCtrl = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  void fetchCart() async {
    setState(() => isLoading = true);
    final data = await _apiService.getCart();
    setState(() {
      cartItems = data;
      isLoading = false;
    });
  }

  void deleteItem(String cartId) async {
    bool success = await _apiService.deleteCartItem(cartId);
    if (success) {
      fetchCart();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Item dihapus")));
      }
    }
  }

  void processCheckout() async {
    Navigator.pop(context);
    setState(() => isLoading = true);

    bool success = await _apiService.checkout(
      postalCode: postalCtrl.text.isNotEmpty ? postalCtrl.text : "12345",
      state: stateCtrl.text.isNotEmpty ? stateCtrl.text : "Banten",
      city: cityCtrl.text.isNotEmpty ? cityCtrl.text : "Pandeglang",
      region: regionCtrl.text.isNotEmpty ? regionCtrl.text : "West",
      shipmodeId: int.tryParse(shipModeCtrl.text) ?? 1,
    );

    setState(() => isLoading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order berhasil dibuat!"),
          backgroundColor: primaryGreen,
        ),
      );
      fetchCart();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal membuat order"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color getStatusColor(String status) {
    return status == "Dikirim" ? primaryGreen : Colors.orange.shade600;
  }

  void showOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Alamat Pengiriman",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _input("Postal Code", postalCtrl),
                _input("State", stateCtrl),
                _input("City", cityCtrl),
                _input("Region", regionCtrl),
                _input("Ship Mode ID (1=Std, 2=Exp)", shipModeCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              onPressed: processCheckout,
              child: const Text("Confirm Order"),
            ),
          ],
        );
      },
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF1F8F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7FDF9),
      appBar: AppBar(
        title: const Text("Keranjang"),
        backgroundColor: Colors.white,
        foregroundColor: primaryGreen,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: cartItems.isEmpty
                      ? const Center(child: Text("Keranjang Kosong"))
                      : ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            // Mapping sesuai JSON dari handler_customer.js -> cartlist
                            final name = item['product_name'] ?? 'Unknown';
                            final price =
                                double.tryParse(item['price'].toString()) ?? 0;
                            final qty = item['quantity'] ?? 0;
                            final cartId = item['cart_id'].toString();

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGreen.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: primaryGreen.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currencyFormatter.format(price),
                                          style: const TextStyle(
                                            color: primaryGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text("Qty: $qty"),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red.shade400,
                                    ),
                                    onPressed: () => deleteItem(cartId),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: cartItems.isEmpty
                        ? null
                        : () => showOrderDialog(context),
                    child: const Text(
                      "ORDER SEKARANG",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
