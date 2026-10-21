import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  static final String baseUrl = dotenv.env['BASE_URL']!;
  static const String _tokenKey = 'auth_token';

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('You are not authenticated. Please log in again.');
    }

    return {..._jsonHeaders, 'token': token};
  }

  Uri _uri(String path) {
    final base = baseUrl.replaceAll(RegExp(r'/$'), '');
    final normalizedPath = path.replaceFirst(RegExp(r'^/'), '');
    return Uri.parse('$base/$normalizedPath');
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = <String, dynamic>{};
    }

    final data = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            'Request failed (${response.statusCode})',
      );
    }

    return data;
  }

  // BLOCK USER
  Future<Map<String, dynamic>> blockUser(String userId) async {
    final response = await http.post(
      _uri('user/$userId/block'),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }

  // UNBLOCK USER
  Future<Map<String, dynamic>> unblockUser(String userId) async {
    final response = await http.delete(
      _uri('user/$userId/block'),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }

  // GET MY BLOCKED USERS
  Future<List<dynamic>> getBlockedUsers() async {
    final response = await http.get(
      _uri('user/me/blocked'),
      headers: await _authHeaders(),
    );

    final data = _parseResponse(response);
    final users = data['blockedUsers'];

    return users is List ? users : [];
  }

  // CHECK BLOCK STATUS
  Future<Map<String, dynamic>> checkUserStatus(String userId) async {
    final response = await http.get(
      _uri('user/$userId/follow-status'),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }

  // SEARCH USERS BY USERNAME
  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      _uri('user/search').replace(
        queryParameters: {
          'q': query.trim(),
          'page': '$page',
          'limit': '$limit',
        },
      ),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }

  // GET BLOCK STATUS
  // GET /user/:userId/block-status
  Future<Map<String, dynamic>> getBlockStatus(String userId) async {
    final response = await http.get(
      _uri('user/$userId/block-status'),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }

  // GET FOLLOWERS
  // GET /user/:userId/followers
  Future<Map<String, dynamic>> getFollowers(String userId) async {
    final response = await http.get(
      _uri('user/$userId/followers'),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }

  // GET FOLLOWING
  // GET /user/:userId/following
  Future<Map<String, dynamic>> getFollowing(String userId) async {
    final response = await http.get(
      _uri('user/$userId/following'),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }

  // GET USER POSTS
  // GET /user/:userId/posts?page=1&limit=10
  Future<Map<String, dynamic>> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      _uri('user/$userId/posts').replace(
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      ),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> removeFollower(String followerId) async {
    final response = await http.delete(
      _uri('user/me/followers/$followerId'),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }
}
