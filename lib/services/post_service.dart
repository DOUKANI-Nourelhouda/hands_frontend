import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class PostService {
  final String baseUrl;
  final String token;

  PostService({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'token': token,
  };

  Uri _uri(String path, {Map<String, String>? queryParameters}) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return Uri.parse('$base$path').replace(queryParameters: queryParameters);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw PostException(
        'The server returned an invalid response.',
        response.statusCode,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw PostException('Unexpected server response.', response.statusCode);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PostException(
        decoded['message']?.toString() ?? 'Request failed.',
        response.statusCode,
      );
    }

    return decoded;
  }

  // CREATE POST

  Future<Map<String, dynamic>> createPost({
    required String category,
    required String caption,
    List<Map<String, dynamic>> media = const [],
  }) async {
    debugPrint('\n========== CREATE POST REQUEST ==========');

    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final uri = Uri.parse('$base/posts/');

    final body = {'category': category, 'caption': caption, 'media': media};

    debugPrint('[CREATE POST] URL: $uri');
    debugPrint('[CREATE POST] Category: $category');
    debugPrint('[CREATE POST] Caption length: ${caption.length}');
    debugPrint('[CREATE POST] Media count: ${media.length}');
    debugPrint('[CREATE POST] Request body: ${jsonEncode(body)}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'token': token},
      body: jsonEncode(body),
    );

    debugPrint('[CREATE POST RESPONSE] Status: ${response.statusCode}');
    debugPrint(
      '[CREATE POST RESPONSE] Content-Type: '
      '${response.headers['content-type']}',
    );
    debugPrint('[CREATE POST RESPONSE] Raw body: ${response.body}');

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      debugPrint('[CREATE POST ERROR] JSON decoding failed: $e');

      throw Exception(
        'Server returned a non-JSON response '
        '(${response.statusCode}): ${response.body}',
      );
    }

    debugPrint('[CREATE POST] Decoded type: ${decoded.runtimeType}');
    debugPrint('[CREATE POST] Decoded data: $decoded');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map
          ? decoded['message']?.toString() ?? response.body
          : response.body;

      throw PostException(message, response.statusCode);
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected server response format: ${response.body}');
    }

    debugPrint('[CREATE POST] SUCCESS');
    debugPrint('==========================================\n');

    return decoded;
  }

  Future<List<Map<String, dynamic>>> uploadMedia(List<XFile> files) async {
    debugPrint('\n========== UPLOAD MEDIA REQUEST ==========');

    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final uri = Uri.parse('$base/posts/upload-media');

    debugPrint('[UPLOAD] URL: $uri');
    debugPrint('[UPLOAD] Number of files: ${files.length}');
    debugPrint('[UPLOAD] Token exists: ${token.isNotEmpty}');

    if (files.isEmpty) {
      debugPrint('[UPLOAD] No files to upload.');
      return [];
    }

    final request = http.MultipartRequest('POST', uri);

    // Do not manually set Content-Type; MultipartRequest adds its boundary.
    request.headers['token'] = token;

    for (final file in files) {
      final extension = p.extension(file.path).toLowerCase();

      final MediaType contentType;

      switch (extension) {
        case '.jpg':
        case '.jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case '.png':
          contentType = MediaType('image', 'png');
          break;
        case '.webp':
          contentType = MediaType('image', 'webp');
          break;
        case '.mp4':
          contentType = MediaType('video', 'mp4');
          break;
        case '.mov':
          contentType = MediaType('video', 'quicktime');
          break;
        case '.webm':
          contentType = MediaType('video', 'webm');
          break;
        default:
          throw Exception('Unsupported media extension: $extension');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'media',
          file.path,
          filename: p.basename(file.path),
          contentType: contentType,
        ),
      );

      print(
        '[UPLOAD] Added ${p.basename(file.path)} '
        'with MIME type $contentType',
      );
    }

    debugPrint('[UPLOAD] Sending multipart request...');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('[UPLOAD RESPONSE] Status: ${response.statusCode}');
    debugPrint('[UPLOAD RESPONSE] Body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PostException(
        'Media upload failed (${response.statusCode}): ${response.body}',
        response.statusCode,
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      debugPrint('[UPLOAD ERROR] Response is not valid JSON: $e');
      throw Exception('Upload endpoint returned non-JSON: ${response.body}');
    }

    debugPrint('[UPLOAD] Decoded response: $decoded');

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Upload endpoint returned unexpected JSON: ${response.body}',
      );
    }

    final rawMedia = decoded['media'];

    if (rawMedia is! List) {
      debugPrint('[UPLOAD ERROR] Missing or invalid "media" field.');
      throw Exception('Upload response does not contain a media list.');
    }

    final media = <Map<String, dynamic>>[];

    for (final item in rawMedia) {
      if (item is Map) {
        media.add(Map<String, dynamic>.from(item));
      } else {
        debugPrint('[UPLOAD WARNING] Unexpected media item: $item');
      }
    }

    debugPrint('[UPLOAD] Final media count: ${media.length}');
    debugPrint('===========================================\n');

    return media;
  }

  // GET ALL POSTS FROM MY RESIDENCE
  Future<Map<String, dynamic>> getPosts({int page = 1, int limit = 10}) async {
    final response = await http.get(
      _uri('/posts/', queryParameters: {'page': '$page', 'limit': '$limit'}),
      headers: _headers,
    );

    return _decodeResponse(response);
  }

  // GET POSTS BY CATEGORY
  Future<Map<String, dynamic>> getPostsByCategory(
    String category, {
    int page = 1,
    int limit = 10,
  }) async {
    final encodedCategory = Uri.encodeComponent(category);

    final response = await http.get(
      Uri.parse(
        '$baseUrl/posts/category/$encodedCategory'
        '?page=$page&limit=$limit',
      ),
      headers: {'Content-Type': 'application/json', 'token': token},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to load posts by category: ${response.statusCode}');
  }

  // GET MY POSTS
  Future<Map<String, dynamic>> getMyPosts({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      _uri(
        '/posts/user/me',
        queryParameters: {'page': '$page', 'limit': '$limit'},
      ),
      headers: _headers,
    );

    return _decodeResponse(response);
  }

  // SEARCH POSTS
  Future<Map<String, dynamic>> searchPosts({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      _uri(
        '/api/posts/search',
        queryParameters: {
          'q': query.trim(),
          'page': '$page',
          'limit': '$limit',
        },
      ),
      headers: _headers,
    );

    return _decodeResponse(response);
  }

  // LIKE POST
  Future<Map<String, dynamic>> likePost(String postId) async {
    final response = await http.post(
      _uri('/posts/$postId/like'),
      headers: _headers,
    );

    return _decodeResponse(response);
  }

  // UNLIKE POST
  Future<Map<String, dynamic>> unlikePost(String postId) async {
    final response = await http.delete(
      _uri('/posts/$postId/like'),
      headers: _headers,
    );

    return _decodeResponse(response);
  }

  // GET COMMENTS
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final response = await http.get(
      _uri('/posts/$postId/comments'),
      headers: _headers,
    );

    final data = _decodeResponse(response);
    final rawComments = data['comments'];

    if (rawComments is! List) return [];

    return rawComments
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ADD COMMENT

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String text,
  }) async {
    final response = await http.post(
      _uri('/posts/$postId/comments'),
      headers: _headers,
      body: jsonEncode({'text': text.trim()}),
    );

    debugPrint('ADD COMMENT STATUS: ${response.statusCode}');
    debugPrint('ADD COMMENT BODY: ${response.body}');

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> editComment({
    required String postId,
    required String commentId,
    required String text,
  }) async {
    final response = await http.put(
      _uri('/posts/$postId/comments/$commentId'),
      headers: _headers,
      body: jsonEncode({'text': text.trim()}),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> replyToComment({
    required String postId,
    required String commentId,
    required String text,
  }) async {
    final response = await http.post(
      _uri('/posts/$postId/comments/$commentId/replies'),
      headers: _headers,
      body: jsonEncode({'text': text.trim()}),
    );

    return _decodeResponse(response);
  }

  // DELETE MY COMMENT
  Future<Map<String, dynamic>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final response = await http.delete(
      _uri('/posts/$postId/comments/$commentId'),
      headers: _headers,
    );

    return _decodeResponse(response);
  }

  // EDIT A REPLY
  Future<Map<String, dynamic>> editReply({
    required String postId,
    required String commentId,
    required String replyId,
    required String text,
  }) async {
    final response = await http.put(
      _uri('/posts/$postId/comments/$commentId/replies/$replyId'),
      headers: _headers,
      body: jsonEncode({'text': text.trim()}),
    );

    return _decodeResponse(response);
  }

  // DELETE A REPLY
  Future<Map<String, dynamic>> deleteReply({
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    final response = await http.delete(
      _uri('/posts/$postId/comments/$commentId/replies/$replyId'),
      headers: _headers,
    );

    return _decodeResponse(response);
  }

  // DELETE MY POST
  // DELETE MY POST
  Future<void> deletePost(String postId) async {
    final response = await http.delete(
      _uri('/posts/$postId'),
      headers: _headers,
    );

    debugPrint('[DELETE POST] Status: ${response.statusCode}');
    debugPrint('[DELETE POST] Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    // Safely handle responses that aren't JSON.
    String message = 'Failed to delete post';

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        message = decoded['message']?.toString() ?? message;
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw PostException(message, response.statusCode);
  }

  // UPDATE MY POST
  Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String category,
    required String caption,
    required List<Map<String, dynamic>> media,
  }) async {
    final response = await http.put(
      _uri('/posts/$postId'),
      headers: _headers,
      body: jsonEncode({
        'category': category,
        'caption': caption,
        'media': media,
      }),
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(body);
    }

    throw PostException(
      body['message']?.toString() ?? 'Failed to update post',
      response.statusCode,
    );
  }

  Future<Map<String, dynamic>> reportPost({
    required String postId,
    required String reason,
    String details = '',
  }) async {
    final response = await http.post(
      _uri('/report/$postId'),
      headers: _headers,
      body: jsonEncode({'reason': reason, 'details': details.trim()}),
    );

    return _decodeResponse(response);
  }
}

class PostException implements Exception {
  final String message;
  final int statusCode;

  const PostException(this.message, this.statusCode);

  @override
  String toString() => message;
}
