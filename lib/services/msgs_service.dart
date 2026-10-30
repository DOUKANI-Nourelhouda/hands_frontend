import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MsgService {
  final String baseUrl;
  final String token;

  MsgService({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'token': token,
  };

  /// Load the current user's direct conversations.
  Future<List<Map<String, dynamic>>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load conversations (${response.statusCode}): '
        '${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    // Supports either a JSON list or { conversations: [...] }.
    final dynamic data = decoded is List ? decoded : decoded['conversations'];

    if (data is! List) {
      throw Exception('Invalid conversations response.');
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Create a conversation, or retrieve an existing one if the backend
  /// implements that behavior.
  Future<Map<String, dynamic>> createConversation(String recipientId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: _headers,
      body: jsonEncode({'recipientId': recipientId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to open conversation (${response.statusCode}): '
        '${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid conversation response.');
    }

    // Supports { conversation: {...} } or a conversation object directly.
    final dynamic conversation = decoded['conversation'] ?? decoded;

    if (conversation is! Map) {
      throw Exception('Conversation not found in response.');
    }

    return Map<String, dynamic>.from(conversation);
  }

  /// Load message history for one conversation.
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$conversationId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load messages (${response.statusCode}): '
        '${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    // Supports [...] or { messages: [...] }.
    final dynamic data = decoded is List ? decoded : decoded['messages'];

    if (data is! List) {
      throw Exception('Invalid messages response.');
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Send a text message to a conversation.
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/$conversationId'),
      headers: _headers,
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to send message (${response.statusCode}): '
        '${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid sent-message response.');
    }

    final dynamic message = decoded['message'] ?? decoded;

    if (message is! Map) {
      throw Exception('Message not found in response.');
    }

    return Map<String, dynamic>.from(message);
  }

  Future<Map<String, dynamic>> deleteConversation(String conversationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/conversations/$conversationId'),
        headers: {'Content-Type': 'application/json', 'token': token},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete conversation');
      }
    } catch (e) {
      debugPrint('Delete conversation error: $e');
      rethrow;
    }
  }

  /// Edit an existing text message.
  Future<Map<String, dynamic>> editMessage({
    required String messageId,
    required String content,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/messages/$messageId'),
      headers: _headers,
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to edit message (${response.statusCode}): ${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid updated-message response.');
    }

    final dynamic message = decoded['message'] ?? decoded;

    if (message is! Map) {
      throw Exception('Updated message not found in response.');
    }

    return Map<String, dynamic>.from(message);
  }

  /// Delete an existing message.
  Future<void> deleteMessage(String messageId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/messages/$messageId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete message (${response.statusCode}): ${response.body}',
      );
    }
  }
}
