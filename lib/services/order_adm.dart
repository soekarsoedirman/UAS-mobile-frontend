import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/orderlist_adm_model.dart';
import '../models/orderdetail_model.dart';
import 'api.dart';

class OrderService {
  // Ganti localhost dengan 10.0.2.2 jika menggunakan Emulator Android
  final String baseUrl = "${ApiService.baseUrl}/order"; 

  Future<List<OrderModel>> getOrderList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Akses Ditolak: Anda bukan Admin/Seller.');
      } else {
        throw Exception('Gagal memuat order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error Service: $e');
    }
  }

  Future<List<OrderDetailModel>> getOrderDetail(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // URL: /order/{id}
    final uri = Uri.parse('$baseUrl/$orderId');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        // Mengembalikan List karena 1 order bisa punya banyak produk
        return data.map((json) => OrderDetailModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error Service Detail: $e');
    }
  }

  Future<bool> confirmOrder(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // URL: /order/{id}
    final uri = Uri.parse('$baseUrl/$orderId');

    try {
      // Menggunakan POST sesuai endpoint backend
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Print error dari backend untuk debugging
        print("Gagal confirm: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Service Confirm: $e");
      return false;
    }
  }
}