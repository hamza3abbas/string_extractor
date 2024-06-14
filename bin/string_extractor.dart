import 'package:args/args.dart';
import 'package:string_extractor/string_extractor.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('sourceDir',
        abbr: 's',
        help: 'The source directory to scan for strings',
        mandatory: true)
    ..addOption('outputFile',
        abbr: 'o',
        help: 'The output file path for the extracted strings',
        mandatory: true)
    ..addFlag('onlyLocalized',
        abbr: 'l', help: 'Extract only localized strings', defaultsTo: false)
    ..addOption('defaultLanguage',
        abbr: 'd',
        help: 'The default language for the localization files',
        defaultsTo: 'en_US')
    ..addMultiOption('locales',
        abbr: 'L', help: 'Other locales to generate files for', defaultsTo: []);

  final argResults = parser.parse(arguments);

  StringExtractor.extractStrings(
    argResults['sourceDir'],
    argResults['outputFile'],
    onlyLocalized: argResults['onlyLocalized'],
    defaultLanguage: argResults['defaultLanguage'],
    otherLocales: argResults['locales'],
  );
}
