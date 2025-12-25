import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/detail_adm.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  final String currentName;
  final double currentPrice;

  const EditProductPage({
    super.key,
    required this.productId,
    required this.currentName,
    required this.currentPrice,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _service = ProductService();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _subCatController; // Idealnya ini dropdown

  bool _isLoading = false;

  // Warna tema (Konsisten dengan halaman lain)
  final Color _primaryColor = const Color(0xFF0D1F3C); // Dark Blue
  final Color _accentColor = const Color(0xFF27AE60);  // Green

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _priceController = TextEditingController(text: widget.currentPrice.toInt().toString());
    _subCatController = TextEditingController(text: "17"); // Default/Placeholder dulu
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _subCatController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _service.updateProduct(
        widget.productId,
        _nameController.text,
        double.parse(_priceController.text),
        int.parse(_subCatController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil diupdate!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Kembali dengan success flag
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
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
          "Edit Produk",
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
                // Header Icon (Edit Note)
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF9F2), // Light Green Background
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
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
                    // Shadow halus
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
                          "Perbarui Informasi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Nama Produk
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration("Nama Produk", Icons.shopping_bag_outlined),
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),

                        // Harga
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _inputDecoration("Harga (\$)", Icons.attach_money),
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),

                        // Sub Kategori ID
                        TextFormField(
                          controller: _subCatController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _inputDecoration("Sub Kategori ID", Icons.category_outlined),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Tombol Aksi
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
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isLoading ? null : _updateProduct,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20, 
                                      width: 20, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    )
                                  : const Text(
                                      "Simpan Perubahan",
                                      style: TextStyle(fontWeight: FontWeight.bold),
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