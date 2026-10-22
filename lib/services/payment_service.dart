import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  static const String _tokenKey = 'auth_token';

  // Build URLs without duplicating /api.
  Uri _uri(String path, [Map<String, String>? query]) {
    final base = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');

    return Uri.parse('$base/$normalizedPath').replace(queryParameters: query);
  }

  // Use the same token header as the rest of your backend requests.
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please log in again.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'token': token,
    };
  }

  // Decode and validate the server response.
  Map<String, dynamic> _parseResponse(http.Response response) {
    dynamic decoded;

    try {
      decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};
    } on FormatException {
      throw Exception('The server returned an invalid response.');
    }

    if (decoded is! Map) {
      throw Exception('Unexpected server response (${response.statusCode}).');
    }

    final data = Map<String, dynamic>.from(decoded);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data['message']?.toString();

      switch (response.statusCode) {
        case 401:
          throw Exception('Please log in again.');
        case 403:
          throw Exception('You are not allowed to perform this action.');
        case 404:
          throw Exception(message ?? 'The requested resource was not found.');
        case 409:
          throw Exception(
            message ?? 'This request conflicts with existing data.',
          );
        default:
          throw Exception(
            message ?? 'Request failed (${response.statusCode}).',
          );
      }
    }

    return data;
  }

  // GET /api/payments/credits
  // Returns freePostsRemaining, paidPostCredits, totalAvailablePosts.
  Future<Map<String, dynamic>> getCredits() async {
    final response = await http.get(
      _uri('payments/credits'),
      headers: await _headers(),
    );

    return _parseResponse(response);
  }

  // POST /api/payments/create
  // packageId: 5_posts, 10_posts, or 20_posts.
  //
  // Returns the full JSON response from your payment controller,
  // including the checkout URL if your controller provides one.
  Future<Map<String, dynamic>> createPostPackagePayment({
    required String packageId,
  }) async {
    const allowedPackages = {'5_posts', '10_posts', '20_posts'};

    if (!allowedPackages.contains(packageId)) {
      throw Exception('Please select a valid post package.');
    }

    final response = await http.post(
      _uri('payments/create'),
      headers: await _headers(),
      body: jsonEncode({'packageId': packageId}),
    );

    return _parseResponse(response);
  }

  // GET /api/payments/purchases
  // Returns { count, purchases }.
  Future<Map<String, dynamic>> getPurchases() async {
    final response = await http.get(
      _uri('payments/purchases'),
      headers: await _headers(),
    );

    return _parseResponse(response);
  }

  // GET /api/payments/summary
  // Returns credits and purchase statistics.
  Future<Map<String, dynamic>> getPaymentSummary() async {
    final response = await http.get(
      _uri('payments/summary'),
      headers: await _headers(),
    );

    return _parseResponse(response);
  }
}
