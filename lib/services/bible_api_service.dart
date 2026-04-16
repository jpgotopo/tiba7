import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BibleApiService {
  static const String baseUrl = 'https://beeble.vercel.app/api/v1/passage';

  /// Formats a passage reference (e.g. "Kej 1:1-31") into the beeble API path.
  /// The data already uses Indonesian abbreviations (Kej, Mat, Mzm, Ams, etc.)
  /// so no translation is needed — just replace spaces with slashes.
  static Future<String?> getPassage(String reference) async {
    if (reference.trim().isEmpty) return null;
    try {
      // Replace space between book and chapter with a slash: "Kej 1:1-31" → "Kej/1:1-31"
      final formattedRef = reference.trim().replaceFirst(' ', '/');
      final encodedRef = Uri.encodeComponent(formattedRef).replaceAll('%2F', '/');
      final uri = Uri.parse('$baseUrl/$encodedRef');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['verses'] != null) {
          final verses = data['data']['verses'] as List;
          return verses.map((v) => '[${v['verse']}] ${v['content']}').join('\n');
        } else {
          return 'Ayat tidak ditemukan.';
        }
      } else {
        debugPrint('API returned status: ${response.statusCode} for $uri');
      }
    } catch (e) {
      debugPrint('Error fetching passage: $e');
    }
    return null;
  }
}
