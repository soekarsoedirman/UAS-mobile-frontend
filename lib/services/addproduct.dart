
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class ProductService {
  final String baseUrl = "${ApiService.baseUrl}/products"; 

  Future<bool> addProduct(String name, int price, int subCatId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "product_name": name,
          "price": price,
          "subkategori_id": subCatId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Gagal: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error Service: $e");
    }
  }
}