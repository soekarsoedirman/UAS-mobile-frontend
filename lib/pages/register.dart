import 'package:flutter/material.dart';
import '../services/api.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  String? selectedSegment;
  bool isLoading = false;

  void handleRegister() async {
    if (usernameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty ||
        selectedSegment == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    setState(() => isLoading = true);

    // Mapping Role ID: 1 = Admin, 2 = Customer
    // Di backend, authregister butuh: username, roleID, email, password, segmen
    // Disini kita asumsi 'Customer' -> roleID 2, yang lain bisa jadi roleID 2 juga tapi beda segmen
    // ATAU Anda bisa set aturan: Jika segment Corporate/Home Office -> Role 1 (Seller/Admin)?
    // Mari asumsi semua register di sini adalah Customer (Role 2) kecuali kita punya opsi khusus.
    // Tapi di UI ada opsi "Corporate". Kita set Role 2 (Customer) untuk semua, karena Admin biasanya dibuat manual di DB.
    int roleId = 2;

    final response = await ApiService().register(
      usernameCtrl.text,
      emailCtrl.text,
      passwordCtrl.text,
      roleId,
      selectedSegment!,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    // Backend return code 201 dengan JSON berisi tokenjwt jika sukses
    if (response['tokenjwt'] != null ||
        response['status'] == 'success' ||
        response.containsKey('username')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi Berhasil! Silakan Login")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Gagal Daftar")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI TETAP SAMA
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Daftar Akun",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Buat akun untuk melanjutkan",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: usernameCtrl,
                    decoration: _inputStyle(
                      hint: "Username",
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailCtrl,
                    decoration: _inputStyle(
                      hint: "Email",
                      icon: Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: _inputStyle(
                      hint: "Password",
                      icon: Icons.lock_outline,
                      suffix: Icons.visibility_off,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: _dropdownStyle("Segmen"),
                    value: selectedSegment,
                    items: const [
                      DropdownMenuItem(
                        value: "Customer",
                        child: Text("Customer"),
                      ),
                      DropdownMenuItem(
                        value: "Home Office",
                        child: Text("Home Office"),
                      ),
                      DropdownMenuItem(
                        value: "Corporate",
                        child: Text("Corporate"),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedSegment = value),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1E36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : handleRegister,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Daftar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Sudah punya akun? Masuk",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle({
    required String hint,
    required IconData icon,
    IconData? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix != null ? Icon(suffix) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _dropdownStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
