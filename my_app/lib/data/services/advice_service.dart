import 'dart:convert';
import 'package:http/http.dart' as http;

class AdviceService {
  static const String _baseUrl = 'https://api.adviceslip.com';

  Future<String> getAdvice() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/advice'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final slip = jsonData['slip'] as Map<String, dynamic>;
        return slip['advice'] as String;
      } else {
        throw Exception('Failed to load advice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching advice: $e');
    }
  }
}

