import 'dart:convert';
import 'dart:io';

class JsonStorage {
  JsonStorage._();

  //AI Generated
  static Future<Directory> _projectRootDir() async {
    var dir = Directory.current;
    for (var i = 0; i < 12; i++) {
      final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
      if (await pubspec.exists()) return dir;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return Directory.current;
  }

  static Future<Directory> _dataDir() async {
    final root = await _projectRootDir();
    final dir = Directory(
      '${root.path}${Platform.pathSeparator}lib${Platform.pathSeparator}data',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> _file(String fileName) async {
    final dir = await _dataDir();
    return File('${dir.path}${Platform.pathSeparator}$fileName');
  }

  static Future<Map<String, dynamic>> readObject(String fileName) async {
    final f = await _file(fileName);
    if (!await f.exists()) return <String, dynamic>{};
    final raw = await f.readAsString();
    if (raw.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, dynamic>{};
      return decoded.cast<String, dynamic>();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static Future<List<dynamic>> readList(String fileName) async {
    final f = await _file(fileName);
    if (!await f.exists()) return <dynamic>[];
    final raw = await f.readAsString();
    if (raw.trim().isEmpty) return <dynamic>[];
    try {
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
    final f = await _file(fileName);
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  static Future<void> writeList(String fileName, List<dynamic> jsonList) async {
    final f = await _file(fileName);
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonList));
  }
}
