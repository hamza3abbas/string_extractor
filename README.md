# StringExtractor

**NOTE: This tool is specifically for GetX ecosystem users who want to extract static strings. Feel free to edit as needed.**

## Overview
`StringExtractor` is a Dart class designed to extract and categorize strings from Dart files. It processes strings found in `.dart` files within a specified directory, categorizes them, and generates JSON, CSV, and Excel files with the extracted strings. The class can also generate localization files for different locales.

## Usage
To use the `StringExtractor` class, call the `extractStrings` method with the source directory and output file path:

```dart
void main() {
  StringExtractor.extractStrings(
    'path/to/source/directory',
    'path/to/output/file',
    onlyLocalized: false,
    defaultLanguage: 'en_US',
    otherLocales: ['es_ES', 'fr_FR'],
  );
}
