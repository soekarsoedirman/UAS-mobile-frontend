import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/list_productadm_model.dart';
import 'api.dart';

class ProductService {
  final String baseUrl = "${ApiService.baseUrl}/products";

  Future<List<Product>> getProducts({
    int page = 1,
    String queryName = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Menyusun Query Parameters
    final Map<String, String> queryParams = {'page': page.toString()};

    if (queryName.isNotEmpty) {
      queryParams['name'] = queryName;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    print("Requesting: $uri");

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

        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat produk: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error Service: $e');
    }
  }
}
