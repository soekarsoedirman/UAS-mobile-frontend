import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api.dart'; // Import API Service

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Warna Tema (Konsisten)
  final Color _primaryColor = const Color(0xFF0D1F3C); // Dark Blue
  final Color _accentColor = const Color(0xFF27AE60);  // Green
  final Color _softGreenBg = const Color(0xFFEAF9F2); // Light Green Background

  final ApiService _apiService = ApiService();
  bool isLoading = true;
  List<dynamic> cartItems = [];

  // Controller untuk input alamat
  final postalCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final regionCtrl = TextEditingController();
  
  // SHIP MODE DROPDOWN (ID & Nama)
  int _selectedShipModeId = 1; // Default Standard Class
  final List<Map<String, dynamic>> _shipModeOptions = [
    {'id': 4, 'name': 'Standard Class'},
    {'id': 3, 'name': 'Second Class'},
    {'id': 1, 'name': 'First Class'},
    {'id': 2, 'name': 'Same Day'},
  ];

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  void fetchCart() async {
    setState(() => isLoading = true);
    // Simulasi data jika API belum siap, atau panggil API asli
    try {
        final data = await _apiService.getCart();
        setState(() {
          cartItems = data;
          isLoading = false;
        });
    } catch (e) {
       // Fallback dummy data for UI testing if API fails
       setState(() {
         isLoading = false;
         cartItems = []; 
       });
    }
  }

  void deleteItem(String cartId) async {
    bool success = await _apiService.deleteCartItem(cartId);
    if (success) {
      fetchCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item dihapus"), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void processCheckout() async {
    Navigator.pop(context); // Tutup dialog
    setState(() => isLoading = true);

    bool success = await _apiService.checkout(
      postalCode: postalCtrl.text.isNotEmpty ? postalCtrl.text : "12345",
      state: stateCtrl.text.isNotEmpty ? stateCtrl.text : "Banten",
      city: cityCtrl.text.isNotEmpty ? cityCtrl.text : "Pandeglang",
      region: regionCtrl.text.isNotEmpty ? regionCtrl.text : "West",
      shipmodeId: _selectedShipModeId, // Mengirim ID yang dipilih dari dropdown
    );

    setState(() => isLoading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Order berhasil dibuat!"),
          backgroundColor: _accentColor,
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

  // Dialog Konfirmasi Order
  void showOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder( // StatefulBuilder agar dropdown bisa update state dalam dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Konfirmasi Pengiriman",
                style: TextStyle(fontWeight: FontWeight.bold, color: _primaryColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _input("Postal Code", postalCtrl),
                    _input("State", stateCtrl),
                    _input("City", cityCtrl),
                    _input("Region", regionCtrl),
                    const SizedBox(height: 12),
                    
                    // DROPDOWN SHIP MODE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedShipModeId,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryColor),
                          style: TextStyle(
                            fontSize: 14, 
                            color: _primaryColor, 
                            fontWeight: FontWeight.w600
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          onChanged: (int? newValue) {
                            setStateDialog(() { // Update state lokal dialog
                              _selectedShipModeId = newValue!;
                            });
                          },
                          items: _shipModeOptions.map<DropdownMenuItem<int>>((Map<String, dynamic> item) {
                            return DropdownMenuItem<int>(
                              value: item['id'] as int,
                              child: Row(
                                children: [
                                  Icon(Icons.local_shipping_outlined, size: 18, color: Colors.grey.shade500),
                                  const SizedBox(width: 12),
                                  Text(item['name'] as String),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Batal", style: TextStyle(color: Colors.grey.shade600)),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: processCheckout,
                  child: const Text("Confirm Order"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Widget Input Helper
  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 1.5),
          ),
        ),
      ),
    );
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
          "Keranjang Belanja",
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey.shade600),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: _accentColor))
          : Column(
              children: [
                Expanded(
                  child: cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_shopping_cart_outlined, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text("Keranjang Kosong", style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            final name = item['product_name'] ?? 'Unknown';
                            final price = double.tryParse(item['price'].toString()) ?? 0;
                            final qty = item['quantity'] ?? 0;
                            final cartId = item['cart_id'].toString();

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
                                      Icons.shopping_bag_outlined,
                                      color: _accentColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // TEXT INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: _primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currencyFormatter.format(price),
                                          style: TextStyle(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Qty: $qty",
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // DELETE BUTTON
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                                    onPressed: () => deleteItem(cartId),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                // BOTTOM CHECKOUT BAR
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor, // Dark Blue Button
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: cartItems.isEmpty
                          ? null
                          : () => showOrderDialog(context),
                      child: const Text(
                        "Checkout Sekarang",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}