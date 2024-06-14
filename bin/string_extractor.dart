#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';
import 'package:string_extractor/core/string_extractor.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('sourceDir',
        abbr: 's', help: 'Source directory to scan for strings')
    ..addOption('outputFile',
        abbr: 'o', help: 'Output file path for the extracted strings')
    ..addFlag('onlyLocalized',
        abbr: 'l', defaultsTo: false, help: 'Extract only localized strings')
    ..addOption('defaultLanguage',
        abbr: 'd',
        defaultsTo: 'en_US',
        help: 'Default language for the localization files')
    ..addMultiOption('locales',
        abbr: 't', help: 'Other locales to generate files for');

  final results = parser.parse(arguments);

  if (!results.wasParsed('sourceDir') || !results.wasParsed('outputFile')) {
    print(
        'Usage: dart bin/string_extractor.dart --sourceDir <source directory> --outputFile <output file path> [options]');
    print(parser.usage);
    exit(1);
  }

  final sourceDir = results['sourceDir'] as String;
  final outputFilePath = results['outputFile'] as String;
  final onlyLocalized = results['onlyLocalized'] as bool;
  final defaultLanguage = results['defaultLanguage'] as String;
  final otherLocales = results['locales'] as List<String>;

  StringExtractor.extractStrings(
    sourceDir,
    outputFilePath,
    onlyLocalized: onlyLocalized,
    defaultLanguage: defaultLanguage,
    otherLocales: otherLocales,
  );
}
