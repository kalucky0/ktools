import 'dart:io';

import 'package:class_generator/class_generator.dart';

import 'config.dart';
import 'utils.dart';

class Asset {
  final String category;
  final String name;
  final String path;

  const Asset(
    this.category,
    this.name,
    this.path,
  );
}

Future<void> generateAssets(Config config) async {
  final dirs = await _getDirs(config.ignoredAssets);
  final assets = await Future.wait(dirs.map(_getAssets));
  final classes = assets.map(_generateClass).join('\n');
  final assetClass = _generateAssetClass(assets.expand((e) => e));
  final assetsFile = File(config.outputAssets);
  await assetsFile.writeAsString(formatDart(_combineAll(assetClass, classes)));
}

String _combineAll(String assetClass, String classes) {
  StringBuffer buffer = StringBuffer();
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln(assetClass);
  buffer.write(classes);
  return buffer.toString();
}

String _generateAssetClass(Iterable<Asset> assets) {
  final categories = assets.map((asset) => asset.category).toSet();
  final builder = ClassBuilder('Assets');
  for (final category in categories) {
    final name = category.capitalize();
    builder.fields.add(
      Field('static const', category)..assignment = '_${name}Assets()',
    );
  }
  return builder.build();
}

String _generateClass(List<Asset> assets) {
  final name = assets.first.category.capitalize();
  final builder = ClassBuilder('_${name}Assets');
  builder.constructors.add(
    Constructor('_${name}Assets')..constant = true,
  );
  for (final asset in assets) {
    builder.fields.add(
      Field('final', asset.name.toCamel())..assignment = '\'${asset.path}\'',
    );
  }
  return builder.build();
}

Future<List<String>> _getDirs(List<String> ignored) async {
  final dir = Directory('assets');
  return dir.list().map((dir) {
    return dir.path.replaceAll('\\', '/');
  }).where((path) {
    return !ignored.contains(path);
  }).toList();
}

Future<List<Asset>> _getAssets(String path) async {
  final dir = Directory(path);
  return dir.list().where((entity) {
    return entity is File;
  }).map((file) {
    final path = file.path.replaceAll('\\', '/');
    final filename = path.split('/').last.split('.').first;
    final category = path.split('/')[1];
    return Asset(category, filename, path);
  }).toList();
}
