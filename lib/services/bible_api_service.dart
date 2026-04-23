import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class BibleApiService {
  static const String baseUrl = 'https://beeble.vercel.app/api/v1/passage';

  /// Check network connectivity
  static Future<bool> _hasNetwork() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) print('Connectivity check failed: $e');
      return false;
    }
  }

  /// Formats a passage reference (e.g. "Kej 1:1-31") into the beeble API path.
  static Future<String?> getPassage(String reference) async {
    if (reference.trim().isEmpty) return null;

    // Check network first
    if (!await _hasNetwork()) {
      return 'Error: Tidak ada koneksi internet';
    }

    try {
      final formattedRef = reference.trim().replaceFirst(' ', '/');
      final encodedRef = Uri.encodeComponent(
        formattedRef,
      ).replaceAll('%2F', '/');
      final uri = Uri.parse('$baseUrl/$encodedRef');

      if (kDebugMode) print('Fetching: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['verses'] != null) {
          final verses = data['data']['verses'] as List;
          return verses
              .map((v) => '[${v['verse']}] ${v['content']}')
              .join('\n');
        } else {
          return 'Ayat tidak ditemukan untuk "$reference"';
        }
      } else {
        return 'Error API (${response.statusCode}): ${response.reasonPhrase}';
      }
    } on SocketException {
      return 'Error: Tidak dapat terhubung ke server (cek koneksi/WiFi)';
    } on HttpException {
      return 'Error: Masalah HTTP';
    } on FormatException {
      return 'Error: Format ayat tidak valid';
    } catch (e) {
      if (kDebugMode) print('Error fetching passage "$reference": $e');
      return 'Error: $e';
    }
  }
}
