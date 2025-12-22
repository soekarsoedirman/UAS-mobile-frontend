import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // --- HELPER: Mengambil Token ---
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- HELPER: Header dengan Token ---
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token", // Sesuai standar JWT
    };
  }

  // ========================================== //
  //             1. AUTHENTICATION              //
  // ========================================== //

  // Endpoint: POST /login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Simpan token ke HP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['token']);
        await prefs.setString(
          'role',
          data['data']['role'],
        ); // "admin" atau "customer"

        return {'status': true, 'data': data['data']};
      } else {
        return {'status': false, 'message': 'Login gagal'};
      }
    } catch (e) {
      return {'status': false, 'message': e.toString()};
    }
  }

  // Endpoint: POST /register
  Future<bool> register(
    String email,
    String password,
    String username,
    int roleID,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "username": username,
          "roleID": roleID, // 1 = user, 2 = penjual (sesuaikan DB)
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error Register: $e");
      return false;
    }
  }

  // Endpoint: POST /logout
  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    final headers = await _getHeaders();

    try {
      await http.post(url, headers: headers);
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus semua data sesi
    } catch (e) {
      print("Logout error: $e");
    }
  }

  // ========================================== //
  //            2. CUSTOMER FEATURES            //
  // ========================================== //

  // Endpoint: GET /home (Kategori & Subkategori)
  Future<List<dynamic>> getHomeData() async {
    final url = Uri.parse('$baseUrl/home');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // Mengembalikan list kategori
    }
    return [];
  }

  // Endpoint: GET /products (Bisa dengan query search)
  Future<List<dynamic>> getProducts({String? query}) async {
    String endpoint = '$baseUrl/products';
    if (query != null && query.isNotEmpty) {
      endpoint += '?query=$query';
    }

    final url = Uri.parse(endpoint);
    // Note: Di rancangan, GET /products biasa tidak butuh Auth, tapi search butuh Auth.
    // Kita kirim header Auth saja untuk aman.
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }
    return [];
  }

  // Endpoint: GET /products/{id} (Detail Produk)
  Future<Map<String, dynamic>?> getProductDetail(String id) async {
    final url = Uri.parse('$baseUrl/products/$id');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }
    return null;
  }

  // Endpoint: POST /products/{id}/cart (Tambah ke Keranjang)
  Future<bool> addToCart(String productId) async {
    final url = Uri.parse('$baseUrl/products/$productId/cart');
    final headers = await _getHeaders();

    final response = await http.post(url, headers: headers);
    return response.statusCode == 200;
  }

  // Endpoint: GET /cart (Lihat Keranjang)
  Future<List<dynamic>> getCart() async {
    final url = Uri.parse('$baseUrl/cart');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }
    return [];
  }

  // Endpoint: DELETE /cart/{id} (Hapus dari keranjang)
  Future<bool> deleteFromCart(String cartId) async {
    final url = Uri.parse('$baseUrl/cart/$cartId');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);
    return response.statusCode == 200;
  }

  // Endpoint: POST /order (Checkout)
  Future<bool> checkoutOrder() async {
    final url = Uri.parse('$baseUrl/order');
    final headers = await _getHeaders();

    final response = await http.post(url, headers: headers);
    return response.statusCode == 200;
  }

  // Endpoint: GET /order/list (Riwayat Pesanan Customer)
  Future<List<dynamic>> getOrderList() async {
    final url = Uri.parse('$baseUrl/order/list');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }
    return [];
  }

  // ========================================== //
  //             3. SELLER FEATURES             //
  // ========================================== //

  // Endpoint: GET /seller/dashboard (Typo di doc: /dasboard -> /seller/dashboard)
  Future<Map<String, dynamic>?> getSellerDashboard() async {
    // Sesuaikan path ini dengan routes.js Anda yang sebenarnya
    final url = Uri.parse('$baseUrl/seller/dashboard');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']['metrics'];
    }
    return null;
  }

  // Endpoint: POST /products (Tambah Produk)
  Future<bool> addProduct(String name, int subCategoryId) async {
    final url = Uri.parse('$baseUrl/products');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"product_name": name, "subkategori_id": subCategoryId}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
