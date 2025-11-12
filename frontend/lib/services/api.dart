import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  // Allow override from --dart-define=BACKEND_BASE_URL=http://<host>:8000
  static const String _envBase = String.fromEnvironment('BACKEND_BASE_URL');
  static String? _overrideBase;

  static void setBaseUrl(String url) {
    _overrideBase = url;
  }

  static String getBaseUrl() {
    return _baseUrl();
  }

  static String _baseUrl() {
    if (_overrideBase != null && _overrideBase!.isNotEmpty)
      return _overrideBase!;
    if (_envBase.isNotEmpty) return _envBase;

    if (!kIsWeb && Platform.isAndroid) {
      // 👇 Check if running on real device or emulator
      // For emulator → 10.0.2.2
      // For physical phone → your PC's local IP
      return const bool.fromEnvironment('IS_PHYSICAL_DEVICE',
              defaultValue: false)
          ? 'http://10.207.33.250:8000' // your PC IP (for real phone)
          : 'http://10.0.2.2:8000'; // emulator
    }

    return 'http://localhost:8000'; // for web/desktop
  }

  static Future<List<String>> generateCaptions(File imageFile) async {
    final url = Uri.parse('${_baseUrl()}/generate-captions');

    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    final contentType = MediaType.parse(mimeType);

    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: contentType,
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      // Try to surface backend error detail when available
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final detail = body['detail']?.toString() ?? response.body;
        throw Exception('Backend ${response.statusCode}: $detail');
      } catch (_) {
        throw Exception(
            'Backend ${response.statusCode}: ${response.reasonPhrase}');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final captions =
        (data['captions'] as List<dynamic>).map((e) => e.toString()).toList();
    return captions;
  }

  // Conversation methods
  static Future<Map<String, dynamic>> createConversation(String token) async {
    final url = Uri.parse('${_baseUrl()}/conversations');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create conversation: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getConversations(String token) async {
    final url = Uri.parse('${_baseUrl()}/conversations');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['conversations'] as List<dynamic>;
    } else {
      throw Exception('Failed to get conversations: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getConversationMessages(
    String token,
    int conversationId,
  ) async {
    final url =
        Uri.parse('${_baseUrl()}/conversations/$conversationId/messages');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['messages'] as List<dynamic>;
    } else {
      throw Exception('Failed to get messages: ${response.statusCode}');
    }
  }

  static Future<void> addMessage(
    String token,
    int conversationId,
    String content,
  ) async {
    final url =
        Uri.parse('${_baseUrl()}/conversations/$conversationId/messages');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'conversation_id': conversationId,
        'content': content,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add message: ${response.statusCode}');
    }
  }

  // Saved captions methods
  static Future<void> saveCaption(String token, String caption) async {
    final url = Uri.parse('${_baseUrl()}/saved-captions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'caption': caption}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save caption: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getSavedCaptions(String token) async {
    final url = Uri.parse('${_baseUrl()}/saved-captions');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['captions'] as List<dynamic>;
    } else {
      throw Exception('Failed to get saved captions: ${response.statusCode}');
    }
  }

  static Future<void> deleteCaption(String token, int captionId) async {
    final url = Uri.parse('${_baseUrl()}/saved-captions/$captionId');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete caption: ${response.statusCode}');
    }
  }
}
