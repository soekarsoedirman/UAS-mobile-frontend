import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detail_adm_model.dart'; // Import Model Baru
import 'api.dart';

class ProductService {
  final String baseUrl = "${ApiService.baseUrl}/products"; 

  Future<ProductDetail> getProductDetail(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('$baseUrl/$id');

    print("Request Detail: $uri");

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
        return ProductDetail.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Gagal memuat detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error Service Detail: $e');
    }
  }

  Future<bool> deleteProduct(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Gagal menghapus: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error Delete: $e');
    }
  }

  Future<bool> updateProduct(String id, String name, double price, int subCategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "product_name": name,
          "price": price,
          "subkategori_id": subCategoryId, 
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Gagal mengupdate: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error Update: $e');
    }
  }
}