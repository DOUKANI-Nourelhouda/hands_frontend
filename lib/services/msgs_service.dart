import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MsgService {
  final AuthService _authService = AuthService();

  String get _baseUrl => AuthService.baseUrl.replaceAll(RegExp(r'/+$'), '');

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getSavedToken();

    if (token == null || token.isEmpty) {
      throw Exception('Your session has expired. Please log in again.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'token': token,
    };
  }

  dynamic _decode(http.Response response) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid server response (${response.statusCode}).');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map ? data['message']?.toString() : null;

      throw Exception(message ?? 'Request failed (${response.statusCode}).');
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final url = '$_baseUrl/conversations';

    print('[MESSAGES] GET $url');

    final response = await http.get(Uri.parse(url), headers: await _headers());

    print('[MESSAGES] Status: ${response.statusCode}');

    final data = _decode(response);

    if (data is! List) {
      throw Exception('Expected a list from GET /conversations.');
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> getOrCreateConversation(String userId) async {
    final url = '$_baseUrl/conversations';

    print('[MESSAGES] POST $url');

    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode({'userId': userId}),
    );

    final data = _decode(response);

    if (data is Map && data['conversation'] is Map) {
      return Map<String, dynamic>.from(data['conversation'] as Map);
    }

    if (data is Map && data['_id'] != null) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('The server did not return a valid conversation.');
  }
}
