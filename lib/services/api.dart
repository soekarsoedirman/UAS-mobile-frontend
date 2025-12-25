import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.10:3000';

  // --- HELPER: GET HEADERS (WITH TOKEN) ---
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- AUTHENTICATION ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      // Decode response agar bisa dibaca UI
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    int roleId,
    String segmen,
  ) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
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
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<bool> logout() async {
    try {
      final url = Uri.parse('$baseUrl/logout');

      await http.post(url);
    } catch (e) {
      print("Logout server error: $e");
    }

    // 2. HAPUS TOKEN DARI HP (PENTING)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    return true;
  }

  // --- PRODUCT & CATEGORY (HOME) ---

  // Endpoint: /home (Home handler)
  Future<List<dynamic>> getCategories() async {
    final url = Uri.parse('$baseUrl/home');

    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      } else if (response.statusCode == 401) {
        print("Token Expired atau Tidak Valid");
        return [];
      }
      return [];
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  // Endpoint: /products (ambil semua produk untuk list)
  Future<List<dynamic>> getProducts() async {
    // URL mengarah ke /products
    final url = Uri.parse('$baseUrl/products');

    // PENTING: Ambil token agar tidak kena Error 401
    final headers = await _getHeaders();

    try {
      // Gunakan http.get
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      } else if (response.statusCode == 401) {
        print("Akses Ditolak: Token Expired atau Tidak Valid");
        return [];
      }
      return [];
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // Endpoint: /product/:id
  Future<Map<String, dynamic>?> getProductDetail(String id) async {
    // PERBAIKAN: Gunakan '/products/' (jamak) sesuai route backend Anda
    final url = Uri.parse('$baseUrl/products/$id');

    // Ambil Token
    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'];
      } else {
        print("Gagal ambil detail (Status: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      print("Error fetching detail: $e");
      return null;
    }
  }

  // Endpoint (Admin): /product (Add Product)
  Future<bool> addProduct(String name, int subCategoryId, double price) async {
    // URL SAMA (/products), TAPI NANTI KITA PAKAI POST
    final url = Uri.parse('$baseUrl/products');

    final headers = await _getHeaders();

    try {
      // Gunakan http.post
      final response = await http.post(
        url,
        headers: headers,
        // Body JSON harus sesuai dengan Joi validation di route.js backend
        body: jsonEncode({
          'product_name': name, // Sesuai Joi.string()
          'price': price, // Sesuai Joi.number()
          'subkategori_id': subCategoryId, // Sesuai Joi.number()
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error add product: $e");
      return false;
    }
  }

  // --- CART & ORDER ---

  // Endpoint: /cart/:id (Add to Cart)
  Future<bool> addToCart(String id, int quantity) async {
    final url = Uri.parse('$baseUrl/products/$id/cart');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error add to cart: $e");
      return false;
    }
  }

  // Endpoint: /cart (Get Cart List)
  Future<List<dynamic>> getCart() async {
    final url = Uri.parse('$baseUrl/cart');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error get cart: $e");
      return [];
    }
  }

  // Endpoint: /cart/:id (Delete/Drop Cart)
  Future<bool> deleteCartItem(String cartId) async {
    final url = Uri.parse('$baseUrl/cart/$cartId');
    final headers = await _getHeaders();
    try {
      final response = await http.delete(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      print("Error delete cart: $e");
      return false;
    }
  }

  // Endpoint: /order (Checkout)
  Future<bool> checkout({
    required String postalCode,
    required String state,
    required String city,
    required String region,
    required int shipmodeId,
  }) async {
    final url = Uri.parse('$baseUrl/order');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'postal_code': postalCode,
          'state': state,
          'city': city,
          'region': region,
          'shipmode_id': shipmodeId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error checkout: $e");
      return false;
    }
  }

  // Endpoint: /order (Get Order List)

  // Endpoint: /order/list (Customer Order History)
  Future<List<dynamic>> getOrderHistory() async {
    final url = Uri.parse('$baseUrl/order/list');

    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      } else if (response.statusCode == 403) {
        print("Akses ditolak: Pastikan login sebagai Customer");
        return [];
      }
      return [];
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }
}
