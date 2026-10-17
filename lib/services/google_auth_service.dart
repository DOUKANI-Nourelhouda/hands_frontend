import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'deviceid_service.dart';

class GoogleAuthService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  static String serverClientId = dotenv.env['SERVERCLIENTID']!;

  static const String _tokenKey = 'auth_token';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;

    await _googleSignIn.initialize(serverClientId: serverClientId);

    _initialized = true;
  }

  Future<Map<String, dynamic>> signIn({String? residence}) async {
    await _initialize();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception(
        'Google authentication is not supported on this platform.',
      );
    }

    final GoogleSignInAccount account = await _googleSignIn.authenticate();

    final googleAuth = account.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google did not return an ID token. Check your OAuth configuration.',
      );
    }

    final String deviceId = await DeviceIdService.getDeviceId();
    debugPrint('GOOGLE DEVICE ID: $deviceId');
    final Map<String, dynamic> body = {
      'idToken': idToken,
      if (residence != null && residence.isNotEmpty) 'residence': residence,
      'deviceId': deviceId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint('GOOGLE LOGIN URL: ${response.request?.url}');
    debugPrint('GOOGLE LOGIN STATUS: ${response.statusCode}');
    debugPrint('GOOGLE LOGIN BODY: ${response.body}');

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
            'Google login failed (${response.statusCode})',
      );
    }

    final appToken = data['token'];

    if (appToken is! String || appToken.isEmpty) {
      throw Exception('The backend did not return an application token.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, appToken);

    return data;
  }
}
