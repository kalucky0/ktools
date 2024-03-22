import 'dart:io';

import 'package:yaml/yaml.dart';

class Config {
  final List<String> ignoredAssets;
  final List<String> ignoredLanguages;
  final String inputTranslations;
  final String outputAssets;
  final String outputTranslations;

  Config._({
    this.ignoredAssets = const [],
    this.ignoredLanguages = const [],
    this.inputTranslations = 'assets/translations',
    this.outputAssets = 'gen/assets.g.dart',
    this.outputTranslations = 'gen/translations.g.dart',
  });

  static Future<Config> read() async {
    final file = File('pubspec.yaml');
    final contents = await file.readAsString();
    final yaml = loadYaml(contents);

    if (yaml is! YamlMap) throw Exception('Invalid pubspec.yaml');
    if (yaml['ktools'] == null) return Config._();

    final ktools = yaml['ktools'];
    List<String> ignoredAssets = [];
    List<String> ignoredLanguages = [];
    String inputTranslations = 'assets/translations';
    String outputAssets = 'lib/gen/assets.g.dart';
    String outputTranslations = 'lib/gen/translations.g.dart';

    if (ktools['ignore'] != null) {
      final ignored = ktools['ignore'];
      if (ignored['assets'] != null) {
        ignoredAssets = List<String>.from(ignored['assets']);
      }
      if (ignored['languages'] != null) {
        ignoredLanguages = List<String>.from(ignored['languages']);
      }
    }
    if (ktools['output'] != null) {
      final output = ktools['output'];
      if (output['translations'] != null) {
        outputTranslations = output['translations'];
      }
      if (output['assets'] != null) {
        outputAssets = output['assets'];
      }
    }
    if (ktools['translations'] != null) {
      inputTranslations = ktools['translations'];
    }

    return Config._(
      inputTranslations: inputTranslations,
      ignoredAssets: ignoredAssets,
      ignoredLanguages: ignoredLanguages,
      outputTranslations: outputTranslations,
      outputAssets: outputAssets,
    );
  }
}
