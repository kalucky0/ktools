/// A library for generating Dart code from assets and translations.
library ktools;

import 'src/config.dart';
import 'src/assets_gen.dart';
import 'src/translations_gen.dart';

/// Runs the specified action based on the given [action] parameter.
///
/// This method reads the configuration using [Config.read] and performs the
/// action based on the value of [action]. If [action] is
/// not recognized, it prints an error message.
Future<void> run(String action) async {
  final config = await Config.read();
  switch (action) {
    case 'assets':
      return generateAssets(config);
    case 'translations':
      return generateTranslations(config);
    default:
      print('Unknown command: $action');
  }
}
