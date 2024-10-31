// lib/repositories/earnings_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/earnings.dart';

class EarningsRepository {
  final String baseUrl = 'https://api.api-ninjas.com/v1/earningscalendar';

  Future<List<Earnings>> fetchEarnings(String ticker) async {
    final response = await http.get(Uri.parse('$baseUrl?ticker=$ticker'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.isEmpty) {
        throw Exception('No earnings data found for the provided ticker.');
      }
      return jsonResponse.map((data) => Earnings.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load earnings data');
    }
  }
}