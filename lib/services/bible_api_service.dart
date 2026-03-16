import 'dart:convert';
import 'package:http/http.dart' as http;

class BibleApiService {
  static const String baseUrl = 'https://beeble.vercel.app/api/v1/passage';

  static final Map<String, String> _bookTranslations = {
    'Kejadian': 'Kej',
    'Matius': 'Mat',
    'Mazmur': 'Mzm',
    'Amsal': 'Ams',
  };

  static Future<String?> getPassage(String reference) async {
    try {
      // Format reference for beeble API: e.g. "Matius 1" -> "Mat/1" or "Amsal 1:1" -> "Ams/1:1"
      String formattedRef = reference;
      _bookTranslations.forEach((id, abbrev) {
        if (formattedRef.startsWith(id)) {
          formattedRef = formattedRef.replaceFirst(id, abbrev);
        }
      });

      // Replace spaces with slashes to match the API structure: /book/chapter/verse
      formattedRef = formattedRef.replaceAll(' ', '/');
      
      final encodedRef = Uri.encodeComponent(formattedRef).replaceAll('%2F', '/');
      final uri = Uri.parse('$baseUrl/$encodedRef');
      
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['verses'] != null) {
          final verses = data['data']['verses'] as List;
          return verses.map((v) => '[${v['verse']}] ${v['content']}').join('\n');
        } else {
           return 'Versículos no encontrados';
        }
      } else {
        print('API returned status: ${response.statusCode} for $uri');
      }
    } catch (e) {
      // print('Error fetching passage: $e');
    }
    return null;
  }
}
