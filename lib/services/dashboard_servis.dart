import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_model.dart';
import 'api.dart';

class DashboardService {
  // URL Endpoint Dashboard
  final String baseUrl = "${ApiService.baseUrl}/dashboard";

  Future<DashboardData> getDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token kosong/expired");
    }

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Backend: { data: { metrics: { ... } } }
        if (responseData['data'] != null &&
            responseData['data']['metrics'] != null) {
          final metrics = responseData['data']['metrics'];
          return DashboardData.fromJson(metrics);
        } else {
          // Fallback jika data kosong
          return DashboardData(
            totalRevenue: 0,
            totalProducts: 0,
            totalTransactions: 0,
          );
        }
      } else {
        throw Exception(
          'Gagal memuat data dashboard. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error Dashboard Service: $e');
    }
  }
}
