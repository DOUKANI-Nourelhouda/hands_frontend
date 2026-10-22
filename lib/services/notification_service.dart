import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => dotenv.env['BASE_URL']!;

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in. Please log in again.');
    }

    return {'Content-Type': 'application/json', 'token': token};
  }

  dynamic _decodeResponse(http.Response response) {
    final dynamic data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map ? data['message']?.toString() : null;

      throw Exception(message ?? 'Request failed (${response.statusCode}).');
    }

    return data;
  }

  /// GET /api/notifications?page=1&limit=20
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_baseUrl/notifications').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    try {
      final response = await _client.get(uri, headers: await _headers());

      final data = _decodeResponse(response);

      if (data is! Map) {
        throw Exception('Invalid notifications response.');
      }

      return Map<String, dynamic>.from(data);
    } catch (e) {
      debugPrint('GET NOTIFICATIONS ERROR: $e');
      rethrow;
    }
  }

  /// GET /api/notifications/unread-count
  Future<int> getUnreadCount() async {
    final uri = Uri.parse('$_baseUrl/notifications/unread-count');

    final response = await _client.get(uri, headers: await _headers());

    final data = _decodeResponse(response);

    if (data is! Map) return 0;

    return (data['unreadCount'] as num?)?.toInt() ?? 0;
  }

  /// PUT /api/notifications/:notificationId/read
  Future<void> markAsRead(String notificationId) async {
    final uri = Uri.parse(
      '$_baseUrl/notifications/${Uri.encodeComponent(notificationId)}/read',
    );

    final response = await _client.put(uri, headers: await _headers());

    _decodeResponse(response);
  }

  /// PUT /api/notifications/read-all
  Future<int> markAllAsRead() async {
    final uri = Uri.parse('$_baseUrl/notifications/read-all');

    final response = await _client.put(uri, headers: await _headers());

    final data = _decodeResponse(response);

    return data is Map ? (data['modifiedCount'] as num?)?.toInt() ?? 0 : 0;
  }

  /// PUT /api/notifications/read-many
  Future<int> markManyAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return 0;

    final uri = Uri.parse('$_baseUrl/notifications/read-many');

    final response = await _client.put(
      uri,
      headers: await _headers(),
      body: jsonEncode({'notificationIds': notificationIds}),
    );

    final data = _decodeResponse(response);

    return data is Map ? (data['modifiedCount'] as num?)?.toInt() ?? 0 : 0;
  }

  /// DELETE /api/notifications/:notificationId
  Future<void> deleteNotification(String notificationId) async {
    final uri = Uri.parse(
      '$_baseUrl/notifications/${Uri.encodeComponent(notificationId)}',
    );

    final response = await _client.delete(uri, headers: await _headers());

    _decodeResponse(response);
  }

  /// DELETE /api/notifications
  Future<int> deleteAllNotifications() async {
    final uri = Uri.parse('$_baseUrl/notifications');

    final response = await _client.delete(uri, headers: await _headers());

    final data = _decodeResponse(response);

    return data is Map ? (data['deletedCount'] as num?)?.toInt() ?? 0 : 0;
  }

  void dispose() {
    _client.close();
  }
}
