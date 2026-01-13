import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JsonStorage {
  JsonStorage._();

  static String _getKey(String fileName) {
    // Remove .json extension if present for cleaner keys
    return fileName.replaceAll('.json', '');
  }

  static Future<Map<String, dynamic>> readObject(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_getKey(fileName));
      if (raw == null || raw.trim().isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, dynamic>{};
      return decoded.cast<String, dynamic>();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static Future<List<dynamic>> readList(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_getKey(fileName));
      if (raw == null || raw.trim().isEmpty) return <dynamic>[];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <dynamic>[];
      return decoded.toList();
    } catch (_) {
      return <dynamic>[];
    }
  }

  static Future<void> writeObject(
    String fileName,
    Map<String, dynamic> json,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _getKey(fileName),
      const JsonEncoder.withIndent('  ').convert(json),
    );
  }

  static Future<void> writeList(String fileName, List<dynamic> jsonList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _getKey(fileName),
      const JsonEncoder.withIndent('  ').convert(jsonList),
    );
  }
}
