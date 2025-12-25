import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/addproduct.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk mengambil input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _subCatController = TextEditingController();

  final ProductService _service = ProductService();
  bool _isLoading = false;

  // Warna tema (Konsisten dengan halaman lain)
  final Color _primaryColor = const Color(0xFF0D1F3C); // Dark Blue
  final Color _accentColor = const Color(0xFF27AE60);  // Green

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _subCatController.dispose();
    super.dispose();
  }

  // Fungsi Submit
  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text;
      final price = int.parse(_priceController.text);
      final subCatId = int.parse(_subCatController.text);

      await _service.addProduct(name, price, subCatId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produk berhasil ditambahkan!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembali dengan nilai true
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper untuk styling input agar rapi & konsisten
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.grey.shade50, // Background input abu-abu muda
      prefixIcon: Icon(icon, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Tambah Produk",
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey.shade600),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Header Icon (Add Cart)
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF9F2), // Light Green Background
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_shopping_cart_rounded,
                    size: 40,
                    color: _accentColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Card Form
                Container(
                  padding: const EdgeInsets.all(24.0),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Informasi Produk",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // ================= NAMA PRODUK =================
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                              "Nama Produk", Icons.shopping_bag_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Nama tidak boleh kosong";
                            }
                            if (value.length < 3) return "Minimal 3 karakter";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ================= HARGA =================
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration:
                              _inputDecoration("Harga (\$)", Icons.attach_money),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Harga wajib diisi";
                            }
                            if (int.tryParse(value) == null) {
                              return "Harus berupa angka";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ================= SUB KATEGORI ID =================
                        TextFormField(
                          controller: _subCatController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _inputDecoration(
                              "Sub Kategori ID", Icons.category_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ID Sub Kategori wajib diisi";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // ================= BUTTON SIMPAN =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Batal',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor, // Dark Blue
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isLoading ? null : _submitData,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      "Simpan Produk",
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}