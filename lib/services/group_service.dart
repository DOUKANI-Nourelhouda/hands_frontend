import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupService {
  // Example: http://10.140.155.2:5000/api
  final String baseUrl;
  final String token;

  GroupService({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'token': token,
  };

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  dynamic _decode(http.Response response) {
    final dynamic body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map
          ? body['message']?.toString() ?? 'Request failed'
          : 'Request failed';

      throw Exception(message);
    }

    return body;
  }

  // GET /api/groups
  Future<List<Map<String, dynamic>>> getGroups() async {
    final response = await http.get(_uri('/groups'), headers: _headers);

    final data = _decode(response);
    final groups = data is Map ? data['groups'] : null;

    if (groups is! List) return [];

    return groups
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // POST /api/groups
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    final response = await http.post(
      _uri('/groups'),
      headers: _headers,
      body: jsonEncode({'name': name.trim(), 'memberIds': memberIds}),
    );

    final data = _decode(response);

    if (data is! Map || data['group'] is! Map) {
      throw Exception('The server returned an invalid group response.');
    }

    return Map<String, dynamic>.from(data['group'] as Map);
  }

  // GET /api/groups/:groupId/messages
  Future<List<Map<String, dynamic>>> getMessages(String groupId) async {
    final response = await http.get(
      _uri('/group/$groupId/messages'),
      headers: _headers,
    );

    final data = _decode(response);
    final messages = data is Map ? data['messages'] : null;

    if (messages is! List) return [];

    return messages
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ADAPT THIS PATH TO YOUR EXISTING STUDENT-SEARCH ROUTE.
  // Expected response: { "users": [ { "_id": "...", "username": "..." } ] }

  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) return [];

    final uri = _uri('/user/search', {
      'q': trimmedQuery,
      'page': '1',
      'limit': '30',
    });

    final response = await http.get(uri, headers: _headers);

    final data = _decode(response);

    if (data is! Map || data['users'] is! List) {
      throw Exception('Invalid response from the student search endpoint.');
    }

    return (data['users'] as List)
        .whereType<Map>()
        .map((user) => Map<String, dynamic>.from(user))
        .toList();
  }
}
