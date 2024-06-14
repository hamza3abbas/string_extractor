import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

class StringExtractor {
  static void extractStrings(String sourceDir, String outputFilePath,
      {bool onlyLocalized = false,
      String defaultLanguage = 'en_US',
      List<String> otherLocales = const []}) {
    final directory = Directory(sourceDir);
    final excludedDirs = ['common', 'generated', 'data', 'routes'];
    final excludedFiles = ['main.dart', 'global.dart', 'firebase_options.dart'];

    if (!directory.existsSync()) {
      if (kDebugMode) {
        print('Source directory does not exist: ${directory.absolute.path}');
      }
      return;
    }

    final extractedStrings = <String, Map<String, String>>{
      'UI': {},
      'ERROR': {},
      'BUTTONS': {},
      'UNDEFINED': {},
      'URL': {},
      'KEY': {},
      'ID': {},
      'CODE': {},
      'COLOR_HEX': {},
    };

    final stringPattern = RegExp(r'''(["'])(?:(?=(\\?))\2.)*?\1''');
    final importPattern = RegExp(r'''^\s*import\s+["\'].*["\'];?$''');
    final uiPattern = RegExp(r'''(["'])(?:(?=(\\?))\2.)*?\1\.ui''');
    final buttonPattern = RegExp(r'''(["'])(?:(?=(\\?))\2.)*?\1\.button''');
    final errorPattern = RegExp(r'''(["'])(?:(?=(\\?))\2.)*?\1\.error''');

    String categorizeString(String str, String extension) {
      switch (extension) {
        case 'ui':
          return 'UI';
        case 'button':
          return 'BUTTONS';
        case 'error':
          return 'ERROR';
        default:
          final unquotedString = str.substring(1, str.length - 1);
          if (RegExp(r'^\d+$').hasMatch(unquotedString)) return 'CODE';
          if (RegExp(r'^#(?:[0-9a-fA-F]{3}){1,2}$').hasMatch(unquotedString)) {
            return 'COLOR_HEX';
          }
          if (RegExp(r'^https?:\/\/|^\/|^assets\/').hasMatch(unquotedString)) {
            return 'URL';
          }
          if (unquotedString.contains('_') || unquotedString.contains('-')) {
            return 'KEY';
          }
          return 'UNDEFINED';
      }
    }

    bool isUnusefulString(String str) {
      final unquotedString = str.substring(1, str.length - 1);
      return unquotedString.isEmpty || unquotedString == 'null';
    }

    void extractLocalizedStrings(String line, String filename) {
      final uiMatches = uiPattern.allMatches(line);
      for (final match in uiMatches) {
        final matchedString = match.group(0) ?? '';
        if (!matchedString.contains('assets/') &&
            !isUnusefulString(matchedString)) {
          final cleanedString = matchedString.replaceFirst('.ui', '');
          final unquotedString =
              cleanedString.substring(1, cleanedString.length - 1);
          final category = categorizeString(cleanedString, 'ui');
          final key =
              '${filename}_${unquotedString.split(' ')[0].replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')}'
                  .toUpperCase();
          extractedStrings[category]?[key] = unquotedString;
        }
      }

      final buttonMatches = buttonPattern.allMatches(line);
      for (final match in buttonMatches) {
        final matchedString = match.group(0) ?? '';
        if (!matchedString.contains('assets/') &&
            !isUnusefulString(matchedString)) {
          final cleanedString = matchedString.replaceFirst('.button', '');
          final unquotedString =
              cleanedString.substring(1, cleanedString.length - 1);
          final category = categorizeString(cleanedString, 'button');
          final key =
              '${filename}_${unquotedString.split(' ')[0].replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')}'
                  .toUpperCase();
          extractedStrings[category]?[key] = unquotedString;
        }
      }

      final errorMatches = errorPattern.allMatches(line);
      for (final match in errorMatches) {
        final matchedString = match.group(0) ?? '';
        if (!matchedString.contains('assets/') &&
            !isUnusefulString(matchedString)) {
          final cleanedString = matchedString.replaceFirst('.error', '');
          final unquotedString =
              cleanedString.substring(1, cleanedString.length - 1);
          final category = categorizeString(cleanedString, 'error');
          final key =
              '${filename}_${unquotedString.split(' ')[0].replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')}'
                  .toUpperCase();
          extractedStrings[category]?[key] = unquotedString;
        }
      }
    }

    void extractNonLocalizedStrings(String line, String filename) {
      final matches = stringPattern.allMatches(line);
      for (final match in matches) {
        final matchedString = match.group(0) ?? '';
        if (!matchedString.contains('assets/') &&
            !isUnusefulString(matchedString)) {
          final unquotedString =
              matchedString.substring(1, matchedString.length - 1);
          final category = categorizeString(matchedString, '');
          final key =
              '${filename}_${unquotedString.split(' ')[0].replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')}'
                  .toUpperCase();
          extractedStrings[category]?[key] = unquotedString;
        }
      }
    }

    void listDartFiles(Directory dir) {
      for (var entity in dir.listSync(recursive: false)) {
        if (entity is Directory) {
          if (!excludedDirs.any((excluded) => entity.path.contains(excluded))) {
            listDartFiles(entity);
          }
        } else if (entity is File && entity.path.endsWith('.dart')) {
          if (!excludedFiles.contains(entity.uri.pathSegments.last)) {
            final filename =
                entity.uri.pathSegments.last.replaceAll('.dart', '');
            final content = entity.readAsStringSync();
            final lines = content.split('\n');

            for (var line in lines) {
              if (!importPattern.hasMatch(line)) {
                extractLocalizedStrings(line, filename);
                if (!onlyLocalized) {
                  extractNonLocalizedStrings(line, filename);
                }
              }
            }
          }
        }
      }
    }

    listDartFiles(directory);

    final relevantCategories = {
      'UI',
      'ERROR',
      'BUTTONS',
      'UNDEFINED',
    };

    final relevantStrings = {
      for (var category in relevantCategories)
        category: extractedStrings[category] ?? {}
    };

    final translationDir =
        Directory('${Directory(outputFilePath).parent.path}/translation_files');
    if (!translationDir.existsSync()) {
      translationDir.createSync();
    }

    final jsonOutputFilePath = '${translationDir.path}/extracted_strings.json';
    try {
      final outputFile = File(jsonOutputFilePath);
      if (!outputFile.existsSync()) {
        outputFile.createSync(recursive: true);
      }
      outputFile.writeAsStringSync(jsonEncode(relevantStrings));
      if (kDebugMode) {
        print('Extracted strings saved to $jsonOutputFilePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to write file: $e');
      }
    }

    generateLocaleFiles(
        relevantStrings, defaultLanguage, otherLocales, translationDir.path);

    generateCSVFile(
        relevantStrings, '${translationDir.path}/extracted_strings.csv');

    generateExcelFile(
        relevantStrings, '${translationDir.path}/extracted_strings.xlsx');
  }

  static void generateLocaleFiles(Map<String, Map<String, String>> strings,
      String defaultLanguage, List<String> locales, String outputDir) {
    void writeFile(String locale) {
      final file = File('$outputDir/$locale.json');
      if (!file.existsSync()) {
        file.createSync();
      }
      file.writeAsStringSync(jsonEncode(strings));
    }

    writeFile(defaultLanguage);

    for (var locale in locales) {
      writeFile(locale);
    }

    if (kDebugMode) {
      print('Localization files generated in $outputDir');
    }
  }

  static void generateCSVFile(
      Map<String, Map<String, String>> strings, String outputFilePath) {
    final rows = <List<String>>[];

    rows.add(['Category', 'Key', 'Value']);
    for (var category in strings.keys) {
      for (var key in strings[category]?.keys ?? []) {
        rows.add([category, key.toString(), strings[category]?[key] ?? '']);
      }
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final file = File(outputFilePath);
    file.writeAsStringSync(csvData);

    if (kDebugMode) {
      print('CSV file generated at $outputFilePath');
    }
  }

  static void generateExcelFile(
      Map<String, Map<String, String>> strings, String outputFilePath) {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow(['Category', 'Key', 'Value']);
    for (var category in strings.keys) {
      for (var key in strings[category]?.keys ?? []) {
        sheet.appendRow([category, key, strings[category]?[key] ?? '']);
      }
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(outputFilePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      if (kDebugMode) {
        print('Excel file generated at $outputFilePath');
      }
    }
  }
}

extension LocalizedString on String {
  String get ui => this;
  String get button => this;
  String get error => this;
}
