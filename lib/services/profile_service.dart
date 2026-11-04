import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  static const String _tokenKey = 'auth_token';

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'token': token,
    };
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');

    return Uri.parse('$base/$normalizedPath').replace(queryParameters: query);
  }

  dynamic _parseResponse(http.Response response) {
    final dynamic data = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map ? data['message']?.toString() : null;

      throw Exception(message ?? 'Request failed (${response.statusCode})');
    }

    return data;
  }

  // GET /user/me
  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await http.get(_uri('user/me'), headers: await _headers());

    final data = _parseResponse(response);

    return Map<String, dynamic>.from(data as Map);
  }

  // GET /user/:userId
  // Response: { user, isFollowing, isFollowedBy, ... }
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await http.get(
      _uri('user/$userId'),
      headers: await _headers(),
    );

    final data = _parseResponse(response);

    return Map<String, dynamic>.from(data as Map);
  }

  // GET /posts/user/me OR /posts/user/:userId
  Future<Map<String, dynamic>> getProfilePosts({
    String? userId,
    int page = 1,
    int limit = 50,
  }) async {
    final path = userId == null || userId.isEmpty
        ? 'posts/user/me'
        : 'posts/user/$userId';

    final response = await http.get(
      _uri(path, {'page': page.toString(), 'limit': limit.toString()}),
      headers: await _headers(),
    );

    final data = _parseResponse(response);

    return Map<String, dynamic>.from(data as Map);
  }

  // POST /user/:userId/follow
  Future<void> followUser(String userId) async {
    final response = await http.post(
      _uri('user/$userId/follow'),
      headers: await _headers(),
    );

    _parseResponse(response);
  }

  // DELETE /user/:userId/follow
  Future<void> unfollowUser(String userId) async {
    final response = await http.delete(
      _uri('user/$userId/follow'),
      headers: await _headers(),
    );

    _parseResponse(response);
  }

  // PUT /user/me
  Future<Map<String, dynamic>> updateMyProfile({
    String? username,
    String? bio,
    String? profilePicture,
    String? residenceId,
  }) async {
    final updates = <String, dynamic>{};

    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (profilePicture != null) {
      updates['profilePicture'] = profilePicture;
    }
    if (residenceId != null) {
      updates['residence'] = residenceId;
    }

    final response = await http.put(
      _uri('user/me'),
      headers: await _headers(),
      body: jsonEncode(updates),
    );

    final data = _parseResponse(response);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> reportUser({
    required String baseUrl,
    required String token,
    required String userId,
    required String reason,
    String details = '',
  }) async {
    final url = Uri.parse(
      '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/report/user/$userId',
    );

    print('\n========== REPORT USER DEBUG ==========');
    print('BASE URL: $baseUrl');
    print('REQUEST URL: $url');
    print('USER ID: $userId');
    print('REASON: $reason');
    print('DETAILS: ${details.trim()}');
    print('TOKEN EXISTS: ${token.isNotEmpty}');
    print('TOKEN LENGTH: ${token.length}');
    print('=======================================\n');

    try {
      print('[REPORT] Sending POST request...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token,
        },
        body: jsonEncode({'reason': reason, 'details': details.trim()}),
      );

      print('\n========== REPORT RESPONSE ==========');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE HEADERS: ${response.headers}');
      print('RESPONSE BODY: ${response.body}');
      print('=====================================\n');

      Map<String, dynamic> data = {};

      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      }

      if (response.statusCode == 201) {
        print('[REPORT] SUCCESS: User reported successfully.');
        return;
      }

      final message =
          data['message']?.toString() ?? 'Could not report this user.';

      print('[REPORT] FAILED: $message');

      switch (response.statusCode) {
        case 400:
          throw Exception(message);
        case 401:
        case 403:
          throw Exception('Please log in again to report this user.');
        case 404:
          throw Exception('This user could not be found.');
        case 409:
          throw Exception('You have already reported this user.');
        default:
          throw Exception('$message (Status code: ${response.statusCode})');
      }
    } on FormatException catch (e, stackTrace) {
      print('[REPORT] JSON FORMAT ERROR: $e');
      print(stackTrace);
      throw Exception('The server returned an invalid response.');
    } on http.ClientException catch (e, stackTrace) {
      print('[REPORT] HTTP CLIENT ERROR: $e');
      print(stackTrace);
      throw Exception(
        'Could not connect to the server. Check your internet connection.',
      );
    } catch (e, stackTrace) {
      print('[REPORT] ERROR: $e');
      print(stackTrace);
      rethrow;
    } finally {
      print('[REPORT] Request finished.');
    }
  }
}
