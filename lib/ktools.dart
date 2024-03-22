library ktools;

import 'src/config.dart';
import 'src/assets_gen.dart';
import 'src/translations_gen.dart';

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
