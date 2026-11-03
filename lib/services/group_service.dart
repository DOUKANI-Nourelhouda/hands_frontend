import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
    final contentType = response.headers['content-type'] ?? '';

    print('[GROUPS] Status: ${response.statusCode}');
    print('[GROUPS] Content-Type: $contentType');
    print('[GROUPS] Response: ${response.body}');

    dynamic body;

    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Groups API returned a non-JSON response '
        '(${response.statusCode}). Check the endpoint URL and backend route.',
      );
    }

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
    final url = Uri.parse('$baseUrl/group');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'token': token},
    );

    debugPrint('[GROUPS] Status: ${response.statusCode}');
    debugPrint('[GROUPS] Response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load groups: ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);

    // The GET endpoint returns a JSON array directly.
    if (decoded is! List) {
      throw Exception('Invalid groups response: expected a JSON list.');
    }

    return decoded
        .whereType<Map>()
        .map((group) => Map<String, dynamic>.from(group))
        .toList();
  }

  // POST /api/groups
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    final response = await http.post(
      _uri('/group'),
      headers: _headers,
      body: jsonEncode({'name': name.trim(), 'memberIds': memberIds}),
    );

    final data = _decode(response);

    if (data is! Map || data['group'] is! Map) {
      throw Exception('The server returned an invalid group response.');
    }

    return Map<String, dynamic>.from(data['group'] as Map);
  }

  // GET /api/group/:groupId/messages
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

  // GET /api/group/:groupId
  Future<Map<String, dynamic>> getGroupDetails(String groupId) async {
    final response = await http.get(_uri('/group/$groupId'), headers: _headers);

    final data = _decode(response);

    if (data is! Map || data['group'] is! Map) {
      throw Exception('Invalid group details response.');
    }

    return Map<String, dynamic>.from(data['group'] as Map);
  }

  // POST /api/group/:groupId/members
  Future<Map<String, dynamic>> addMembers(
    String groupId,
    List<String> memberIds,
  ) async {
    final response = await http.post(
      _uri('/group/$groupId/members'),
      headers: _headers,
      body: jsonEncode({'memberIds': memberIds}),
    );

    final data = _decode(response);

    if (data is! Map || data['group'] is! Map) {
      throw Exception('Invalid response after adding members.');
    }

    return Map<String, dynamic>.from(data['group'] as Map);
  }

  // DELETE /api/group/:groupId/members/:memberId
  Future<Map<String, dynamic>> removeMember(
    String groupId,
    String memberId,
  ) async {
    final response = await http.delete(
      _uri('/group/$groupId/members/$memberId'),
      headers: _headers,
    );

    final data = _decode(response);

    if (data is! Map || data['group'] is! Map) {
      throw Exception('Invalid response after removing member.');
    }

    return Map<String, dynamic>.from(data['group'] as Map);
  }

  Future<Map<String, dynamic>> editGroupMessage({
    required String groupId,
    required String messageId,
    required String content,
  }) async {
    final response = await http.put(
      _uri('/group/$groupId/messages/$messageId'),
      headers: _headers,
      body: jsonEncode({'text': content}),
    );

    final data = _decode(response);

    if (data is! Map || data['updatedMessage'] is! Map) {
      throw Exception('Updated message was not returned by the server.');
    }

    return Map<String, dynamic>.from(data['updatedMessage']);
  }

  Future<void> deleteGroupMessage({
    required String groupId,
    required String messageId,
  }) async {
    final response = await http.delete(
      _uri('/group/$groupId/messages/$messageId'),
      headers: _headers,
    );

    _decode(response);
  }

  Future<void> leaveGroup(String groupId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/group/$groupId/leave'),
      headers: {'Content-Type': 'application/json', 'token': token},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to leave group (${response.statusCode}): '
        '${response.body}',
      );
    }
  }
}
