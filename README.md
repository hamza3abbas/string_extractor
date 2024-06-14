# StringExtractor

**NOTE: This tool is specifically for extracting static strings and categorizing them. Feel free to edit as needed.**

## Overview
`StringExtractor` is a Dart class designed to extract and categorize strings from Dart files. It processes strings found in `.dart` files within a specified directory, categorizes them, and generates JSON, CSV, and Excel files with the extracted strings. The class can also generate localization files for different locales.

## Description of Keys

- `--sourceDir`: Specifies the source directory where `.dart` files are located.  
  Example: `./lib`

- `--outputFile`: Specifies the output file path where the extracted strings will be saved.  
  Example: `./`

- `--onlyLocalized`: Optional. Pass this flag if you want to extract strings marked with specific extensions provided by this package (e.g., `1-String.ui`, `2-String.button`, `3-String.error`).

- `--defaultLanguage`: Sets the default language for the localization files.  
  Example: `en_US`

- `--locales`: Specifies other locales for which localization files should be generated.  
  Example: `ar_SA`

## CLI Usage

To use the `StringExtractor` class from the CLI, use the following command:

```sh
string_extractor --sourceDir ./lib --outputFile ./ --defaultLanguage en_US --locales ar_SA
