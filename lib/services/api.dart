import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  // --- 1. TOKEN HELPER (Ini fungsi getHeaders yang hilang) ---
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- 2. AUTHENTICATION ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    int roleId,
    String segmen,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'roleID': roleId,
          'segmen': segmen,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Koneksi gagal: $e'};
    }
  }

  // --- 3. ADMIN DASHBOARD ---
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      print("Dashboard Error: $e");
      return {'status': 'error'};
    }
  }

  // --- 4. PRODUK (LIST & DETAIL) ---

  // Ambil List Produk (Public)
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      final json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        return json['data'];
      }
      return [];
    } catch (e) {
      print("Error getProducts: $e");
      return [];
    }
  }

  // Tambah Produk Baru (Admin)
  Future<bool> addProduct(String name, int subCatId, double price) async {
    final headers = await getHeaders();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: jsonEncode({
          'product_name': name,
          'subkategori_id': subCatId,
          'price': price,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error addProduct: $e");
      return false;
    }
  }

  // Ambil Detail Produk
  Future<Map<String, dynamic>?> getProductDetail(String id) async {
    final headers = await getHeaders(); // Sekarang fungsi ini sudah dikenali
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
      );
      final json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        return json['data'];
      }
      return null;
    } catch (e) {
      print("Error detail: $e");
      return null;
    }
  }

  // --- 5. TRANSAKSI (CART) ---

  // Tambah ke Keranjang
  Future<bool> addToCart(String productId, int quantity) async {
    final headers = await getHeaders();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/$productId/cart'),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error cart: $e");
      return false;
    }
  }
}
