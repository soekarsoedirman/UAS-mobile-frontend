import 'package:flutter/material.dart';
import '../services/api.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameCtrl = TextEditingController();
  final subCatCtrl = TextEditingController();
  final priceCtrl = TextEditingController(); // Controller Harga Baru
  bool isLoading = false;

  void saveProduct() async {
    final name = nameCtrl.text;
    final subCat = int.tryParse(subCatCtrl.text) ?? 0;
    final price = double.tryParse(priceCtrl.text) ?? 0.0;

    if (name.isEmpty || subCat == 0 || price == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Isi Nama, ID Sub Kategori (Angka), dan Harga"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    bool success = await ApiService().addProduct(name, subCat, price);
    setState(() => isLoading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Produk Berhasil Disimpan")));
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menyimpan produk")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Produk"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Nama Produk",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subCatCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "ID Sub Kategori (Contoh: 1, 17)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Input Harga Baru
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Harga (Rp)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: isLoading ? null : saveProduct,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
