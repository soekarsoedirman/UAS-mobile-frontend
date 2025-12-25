import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

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

  // Endpoint: /search (ambil semua produk untuk list)
  Future<List<dynamic>> getProducts() async {
    final url = Uri.parse(
      '$baseUrl/search',
    ); // Default search tanpa query = all products limit 10
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // Endpoint: /product/:id
  Future<Map<String, dynamic>?> getProductDetail(String id) async {
    final url = Uri.parse('$baseUrl/product/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'];
      }
      return null;
    } catch (e) {
      print("Error fetching detail: $e");
      return null;
    }
  }

  // Endpoint (Admin): /product (Add Product)
  Future<bool> addProduct(String name, int subCategoryId, double price) async {
    final url = Uri.parse('$baseUrl/product');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'product_name': name,
          'subkategori_id': subCategoryId,
          'price': price,
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
  Future<bool> addToCart(String productId, int quantity) async {
    final url = Uri.parse('$baseUrl/cart/$productId');
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
