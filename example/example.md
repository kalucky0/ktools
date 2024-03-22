## Usage

First, add KTools to your `pubspec.yaml`:

```yaml
dev_dependencies:
  ktools: ^1.0.0
```

Then, run the following command to generate code:

```bash
dart run ktools [action]
```

This will generate Dart code for your assets or translations, which you can then use in your application.

## Configuration

You can configure KTools through the `pubspec.yaml` file. Here is an example configuration:

```yaml
ktools:
    ignore:
        assets: ['path/to/ignore']
        languages: ['en', 'es']
    translations: 'path/to/translations'
    output:
        assets: 'lib/gen/assets.g.dart'
        translations: 'lib/gen/translations.g.dart'
```

In this configuration:
- `ignore.assets` is a list of asset paths to ignore.
- `ignore.languages` is a list of language codes to ignore in translations.
- `translations is` the path to the translations directory.
- `output.assets` is the path to the generated assets Dart file.
- `output.translations` is the path to the generated translations Dart file.