import 'dart:convert';
import 'dart:io';

extension StringExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String toCamel() {
    final parts = split(RegExp(r'[_-]'));
    final camel = parts[0] + parts.sublist(1).map((s) => s.capitalize()).join();
    return camel;
  }
}

String capitalize(String s) => s.capitalize();

String formatDart(String file) {
  return file.replaceAll('class', '\nclass').replaceAll(' {\n', ' {');
}

Future<T> readJson<T>(String filepath) async {
  final file = File(filepath);
  final contents = await file.readAsString();
  return jsonDecode(contents) as T;
}
