import 'dart:io';

import 'package:class_generator/class_generator.dart';

import 'config.dart';
import 'utils.dart';

class Translation {
  final String category;
  final String key;
  final List<String?> vars;

  const Translation(
    this.category,
    this.key,
    this.vars,
  );
}

Future<void> generateTranslations(Config config) async {
  final translationsDir = Directory(config.inputTranslations);
  final translationFiles = await translationsDir.list().where((file) {
    return config.ignoredLanguages.every((lang) {
      return !file.path.contains(lang);
    });
  }).toList();

  if (!await _verifyFiles(translationFiles)) return;

  final json = await readJson(translationFiles.first.path);
  final keys = _getKeys(json);
  final file = _generateAll(keys);
  final translationFile = File(config.outputTranslations);
  await translationFile.writeAsString(formatDart(file));
}

List<Translation> _getKeys(Map<String, dynamic> json) {
  List<Translation> keys = [];

  for (var category in json.keys) {
    if (json[category] is Map) {
      for (var key in json[category].keys) {
        keys.add(Translation(category, key, _getVars(json[category][key])));
      }
    } else if (json[category] is String) {
      final parts = category.split('.');
      keys.add(Translation(parts[0], parts[1], _getVars(json[category])));
    }
  }

  return keys;
}

List<String> _getVars(String text) {
  return RegExp(r'{(.*?)}')
      .allMatches(text)
      .map((e) => e.group(1))
      .nonNulls
      .toList();
}

Future<bool> _verifyFiles(List<FileSystemEntity> files) async {
  Set<String> translationKeys = {};
  bool isSuccessful = true;

  for (final file in files) {
    final json = await readJson<Map<String, dynamic>>(file.path);
    for (final key in json.keys) {
      if (json[key] is Map) {
        for (final subKey in json[key].keys) {
          translationKeys.add('$key.$subKey');
        }
      } else if (json[key] is String) {
        translationKeys.add(key);
      }
    }
  }

  for (final file in files) {
    final json = await readJson<Map<String, dynamic>>(file.path);
    final fileKeys = <String>[];
    for (final key in json.keys) {
      if (json[key] is Map) {
        for (final subKey in json[key].keys) {
          if (json[key][subKey].contains('{}')) {
            print('Missing variable in $key.$subKey in ${file.path}');
            isSuccessful = false;
          }
          fileKeys.add('$key.$subKey');
        }
      } else if (json[key] is String) {
        if (json[key].contains('{}')) {
          print('Missing variable in $key in ${file.path}');
          isSuccessful = false;
        }
        fileKeys.add(key);
      }
    }
    for (final key in translationKeys) {
      if (!fileKeys.contains(key)) {
        print('Missing key $key in ${file.path}');
        isSuccessful = false;
      }
    }
  }

  return isSuccessful;
}

String _generateAll(List<Translation> tr) {
  final keys = tr.map((e) => e.category).toSet().toList();
  final builder = StringBuffer('// GENERATED CODE - DO NOT MODIFY BY HAND\n');
  builder.writeln(
    "import 'package:easy_localization/easy_localization.dart';",
  );

  builder.writeln(_generateTrClass(tr));

  for (final key in keys) {
    builder.writeln(
      _generateClass(tr.where((e) => e.category == key).toList()),
    );
  }

  return builder.toString();
}

String _generateTrClass(List<Translation> tr) {
  final builder = ClassBuilder('Tr');
  final keys = tr.map((e) => e.category).toSet().toList();
  for (final key in keys) {
    builder.fields.add(
      Field('static const', key)..assignment = '_${key.capitalize()}Tr()',
    );
  }
  return builder.build();
}

String _generateClass(List<Translation> tr) {
  final name = tr.first.category.capitalize();
  final builder = ClassBuilder('_${name}Tr');
  builder.constructors.add(
    Constructor('_${name}Tr')..constant = true,
  );
  for (final t in tr) {
    final params = t.vars.map(
      (e) => Parameter('required String', e!)..named = true,
    );
    final args = ', namedArgs: {${t.vars.map((e) {
      return '\'$e\': $e';
    }).join(', ')}}';
    builder.methods.add(
      Method('String', t.key)
        ..getter = t.vars.isEmpty
        ..parameters.addAll(params)
        ..body = 'tr(\'${t.category}.${t.key}\'${t.vars.isEmpty ? '' : args});',
    );
  }
  return builder.build();
}
