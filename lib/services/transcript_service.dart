import 'dart:convert';
import 'package:assignment/models/transcript.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TranscriptService {
  static const String baseUrl ='https://api.api-ninjas.com/v1';

  Future<TranscriptModel> getTranscript({
  required String ticker,
  required String year,
  required String quarter,
}) async {
  try {
    final url = '$baseUrl/earningstranscript?ticker=$ticker&year=$year&quarter=$quarter';
    print('Requesting URL: $url'); // Debug print

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-Api-Key':  dotenv.env['API_NINJA_KEY'] ?? '',
        'Content-Type': 'application/json',
      },
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      // Handle empty response cases
      if (jsonData == null || 
          jsonData.toString().isEmpty || 
          jsonData.toString() == '[]' ||
          (jsonData is List && jsonData.isEmpty) || 
          (jsonData is Map && jsonData.isEmpty)) {
        return TranscriptModel(
          content: 'No transcript available for $ticker Q$quarter $year',
          quarter: quarter,
          year: year,
          ticker: ticker,
        );
      }
        // Fix type casting
        if (jsonData is List && jsonData.isNotEmpty) {
          // Cast List first element to Map<String, dynamic>
          final Map<String, dynamic> firstItem = Map<String, dynamic>.from(jsonData.first as Map);
          return TranscriptModel.fromJson(firstItem);
        } else if (jsonData is Map) {
          // Cast Map to Map<String, dynamic>
          final Map<String, dynamic> data = Map<String, dynamic>.from(jsonData);
          return TranscriptModel.fromJson(data);
        }
    }
    
    // Handle empty response as a special case
    if (response.statusCode == 404 || response.body.isEmpty || response.body == '[]') {
      return TranscriptModel(
        content: 'No transcript available for $ticker Q$quarter $year',
        quarter: quarter,
        year: year,
        ticker: ticker,
      );
    }

    throw Exception('Failed to load transcript: ${response.statusCode}');
  } catch (e) {
    print('Service Error: $e');
    throw Exception('empty response');
  }
}
}
