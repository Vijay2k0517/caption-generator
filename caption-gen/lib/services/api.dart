import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static String _baseUrl() {
    // Adjust host for Android emulator vs others; update if deploying.
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Host loopback for Android emulator
    }
    return 'http://localhost:8000';
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
}
