import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/statistik_model.dart';
import 'api.dart';

class DashboardService {
  // Gunakan 10.0.2.2 untuk Emulator Android
  final String baseUrl = "${ApiService.baseUrl}/statistik";

  Future<DashboardData> getDashboardData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login ulang.");
    }

    // 2. Siapkan Query Params
    final Map<String, String> queryParams = {};

    if (startDate != null) {
      queryParams['start_date'] = DateFormat('yyyy-MM-dd').format(startDate);
    }

    if (endDate != null) {
      queryParams['end_date'] = DateFormat('yyyy-MM-dd').format(endDate);
    }

    final uri = Uri.parse(
      baseUrl,
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData['data'] == null) {
          throw Exception("Key 'data' tidak ditemukan dari server");
        }

        // Parse JSON ke Model
        return DashboardData.fromJson(jsonData['data']);
      } else {
        throw Exception("API Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      // print("Error Service Statistik: $e");
      rethrow;
    }
  }
}
