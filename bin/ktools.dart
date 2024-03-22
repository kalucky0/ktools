import 'package:ktools/ktools.dart' as ktools;

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: generate <name>');
    return;
  }
  return ktools.run(args[0]);
}
