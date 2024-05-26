# KTools

![Code license (MIT)](https://img.shields.io/github/license/kalucky0/ktools)
![Pub Version](https://img.shields.io/pub/v/ktools)
![GitHub issues](https://img.shields.io/github/issues/kalucky0/ktools)

KTools provides utilities for generating code for assets and translations in your Dart or Flutter project.

## Features

- **Asset Code Generation**: Automatically generates Dart code for your assets, making them easily accessible in your code.
- **Translation Code Generation**: Generates Dart code for your translations, allowing for easy localization of your application.
- **Configurable**: Configure ignored assets, ignored languages, input translations, and output paths through the `pubspec.yaml` file.

## Usage

First, add KTools to your `pubspec.yaml`:

```yaml
dev_dependencies:
  ktools: ^1.1.0
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

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License

This project is licensed under the MIT License. See the [`LICENSE`](https://github.com/kalucky0/ktools/blob/master/LICENSE) file for details.