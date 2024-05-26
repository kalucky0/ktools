import 'dart:io';

import 'package:class_generator/class_generator.dart';

import 'config.dart';
import 'utils.dart';

class Translation {
  final String category;
  final String key;
  final List<String?> vars;
  final bool isGendered;
  final bool isPlural;

  const Translation(
    this.category,
    this.key,
    this.vars, [
    this.isGendered = false,
    this.isPlural = false,
  ]);
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
        if (json[category][key] is Map) {
          final trKeys = json[category][key].keys;
          final vars = <String>{};
          for (final k in trKeys) {
            vars.addAll(_getVars(json[category][key][k]));
          }

          bool isGendered = ['male', 'female'].any(trKeys.contains);
          bool isPlural = ['one', 'two' 'few', 'many'].any(trKeys.contains);

          keys.add(
            Translation(category, key, vars.toList(), isGendered, isPlural),
          );
        } else if (json[category][key] is String) {
          keys.add(Translation(category, key, _getVars(json[category][key])));
        }
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
          if (json[key][subKey] is String) {
            isSuccessful = _checkForEmptyVars(
              json[key][subKey],
              '$key.$subKey',
              file.path,
            );
            fileKeys.add('$key.$subKey');
          } else {
            for (final subSubKey in json[key][subKey].keys) {
              isSuccessful = _checkForEmptyVars(
                json[key][subKey][subSubKey],
                '$key.$subKey.$subSubKey',
                file.path,
              );
              fileKeys.add('$key.$subKey.$subSubKey');
            }
            fileKeys.add('$key.$subKey');
          }
        }
      } else if (json[key] is String) {
        isSuccessful = _checkForEmptyVars(json[key], key, file.path);
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

bool _checkForEmptyVars(String line, String key, String file) {
  if (line.contains('{}')) {
    print('Missing variable in $key in $file');
    return false;
  }
  return true;
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
    final params = [];
    if (t.isGendered) {
      params.add(
        Parameter('String?', 'gender')..named = true,
      );
    }
    if (t.isPlural) {
      params.add(
        Parameter('num', 'value'),
      );
    }
    params.addAll(
      t.vars.map((e) => Parameter('required String', e!)..named = true),
    );

    final args = t.vars.map((e) => '\'$e\': $e').join(', ');
    String body = '';
    if (t.isPlural) {
      body = 'plural(';
      body += '\'${t.category}.${t.key}\'';
      body += ', value';
      if (t.vars.isNotEmpty) {
        body += ', namedArgs: {$args},\n';
        body = 'return $body';
      }
      body += ');';
    } else if (t.isGendered) {
      body = 'tr(';
      body += '\'${t.category}.${t.key}\'';
      body += ', gender: gender';
      if (t.vars.isNotEmpty) {
        body += ', namedArgs: {$args},\n';
        body = 'return $body';
      }
      body += ');';
    } else if (t.vars.isNotEmpty) {
      body = 'return tr(\'${t.category}.${t.key}\', namedArgs: {$args},\n);';
    } else {
      body = 'tr(\'${t.category}.${t.key}\');';
    }

    builder.methods.add(
      Method('String', t.key)
        ..getter = params.isEmpty
        ..parameters.addAll(Iterable.castFrom(params))
        ..body = body,
    );
  }
  return builder.build();
}
