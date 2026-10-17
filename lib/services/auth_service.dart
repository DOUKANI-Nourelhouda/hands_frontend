import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:hands/services/deviceid_service.dart';

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  static const String _tokenKey = 'auth_token';

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    return {..._jsonHeaders, if (token != null) 'token': token};
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = <String, dynamic>{};
    }

    final data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            'Request failed (${response.statusCode})',
      );
    }

    return data;
  }

  Future<void> _saveToken(Map<String, dynamic> data) async {
    final token = data['token'];

    if (token is String && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String residence,
  }) async {
    final deviceId = await DeviceIdService.getDeviceId();
    debugPrint('SIGNUP DEVICE ID: $deviceId');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'residence': residence,
        'deviceId': deviceId,
      }),
    );
    debugPrint('REGISTER URL: ${response.request?.url}');
    debugPrint('REGISTER STATUS: ${response.statusCode}');
    debugPrint('REGISTER BODY: ${response.body}');
    final data = _parseResponse(response);
    await _saveToken(data);
    return data;
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _parseResponse(response);
    await _saveToken(data);
    return data;
  }

  // GET CURRENT USER
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _authHeaders(),
    );

    return _parseResponse(response);
  }

  // RESEND VERIFICATION EMAIL
  Future<Map<String, dynamic>> resendVerificationEmail({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend-verification'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );

    return _parseResponse(response);
  }

  // FORGOT PASSWORD
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );

    return _parseResponse(response);
  }

  // RESET PASSWORD
  Future<Map<String, dynamic>> resetPassword({
    required String id,
    required String resetToken,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password/$id/$resetToken'),
      headers: _jsonHeaders,
      body: jsonEncode({'password': password}),
    );

    return _parseResponse(response);
  }

  // UPDATE USER
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/$userId'),
      headers: await _authHeaders(),
      body: jsonEncode(updates),
    );

    return _parseResponse(response);
  }

  // DELETE ACCOUNT
  Future<Map<String, dynamic>> deleteAccount() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/auth/delete-account'),
      headers: await _authHeaders(),
    );

    final data = _parseResponse(response);
    await logout();
    return data;
  }

  // LOGOUT

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      // The token is invalid, expired, or the user no longer exists.
      await logout();
      return false;
    }
  }
}
