import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResidenceService {
  static final String _baseUrl = '${dotenv.env['BASE_URL']}/residences';

  /// Get all active residences.
  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));
    return _handleResponse(response);
  }

  /// Get active residences belonging to a specific wilaya.
  static Future<List<Map<String, dynamic>>> getByWilaya(String wilaya) async {
    final encodedWilaya = Uri.encodeComponent(wilaya);

    final response = await http.get(
      Uri.parse('$_baseUrl/wilaya/$encodedWilaya'),
    );

    return _handleResponse(response);
  }

  /// Search active residences by name.
  static Future<List<Map<String, dynamic>>> search(String query) async {
    final uri = Uri.parse(
      '$_baseUrl/search',
    ).replace(queryParameters: {'q': query});

    final response = await http.get(uri);
    return _handleResponse(response);
  }

  /// Get one residence by MongoDB ID.
  static Future<Map<String, dynamic>> getById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }

    throw Exception(
      jsonDecode(response.body)['message'] ?? 'Failed to get residence',
    );
  }

  static List<Map<String, dynamic>> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    }

    String message = 'Failed to load residences';

    try {
      message = jsonDecode(response.body)['message'] ?? message;
    } catch (_) {}

    throw Exception(message);
  }
}
