import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:pana/pana.dart';
import 'package:pana/src/license.dart';
import 'package:path/path.dart';
import 'package:tint/tint.dart';

const possibleLicenseFileNames = [
  // LICENSE
  'LICENSE',
  'LICENSE.md',
  'license',
  'license.md',
  'License',
  'License.md',
  // LICENCE
  'LICENCE',
  'LICENCE.md',
  'licence',
  'licence.md',
  'Licence',
  'Licence.md',
  // COPYING
  'COPYING',
  'COPYING.md',
  'copying',
  'copying.md',
  'Copying',
  'Copying.md',
  // UNLICENSE
  'UNLICENSE',
  'UNLICENSE.md',
  'unlicense',
  'unlicense.md',
  'Unlicense',
  'Unlicense.md',
];

void main(List<String> arguments) async {
  final argParser = ArgParser();
  argParser.addFlag(
    'show-transitive-dependencies',
    abbr: 't',
    negatable: false,
    help: 'Show transitive dependencies.',
    defaultsTo: false,
  );
  argParser.addFlag(
    'pretty-print',
    abbr: 'p',
    negatable: false,
    help: 'Pretty-print the results.',
    defaultsTo: false,
  );
  argParser.addOption(
    'format',
    abbr: 'f',
    allowed: ['tsv', 'csv', 'json'],
    help: 'Specify output format.',
    defaultsTo: 'json',
  );
  argParser.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'print this help.',
    defaultsTo: false,
  );

  final argResults = argParser.parse(arguments);

  if (argResults['help']) {
    print(argParser.usage);
    exit(0);
  }

  final showTransitiveDependencies =
      argResults['show-transitive-dependencies'] as bool;
  final prettyPrint = argResults['pretty-print'] as bool;
  final outputFormat = argResults['format'];

  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    stderr.writeln('pubspec.yaml file not found in current directory'.red());
    exit(1);
  }

  final pubspec = Pubspec.parseYaml(pubspecFile.readAsStringSync());

  final packageConfigFile = File('.dart_tool/package_config.json');

  if (!pubspecFile.existsSync()) {
    stderr.writeln(
        '.dart_tool/package_config.json file not found in current directory. You may need to run "flutter pub get" or "pub get"'
            .red());
    exit(1);
  }

  print('Checking dependencies...'.blue());

  final packageConfig = json.decode(packageConfigFile.readAsStringSync());

  final res = [];

  for (final package in packageConfig['packages']) {
    final name = package['name'];

    if (!showTransitiveDependencies) {
      if (!pubspec.dependencies.containsKey(name)) {
        continue;
      }
    }

    String rootUri = package['rootUri'];
    if (rootUri.startsWith('file://')) {
      if (Platform.isWindows) {
        rootUri = rootUri.substring(8);
      } else {
        rootUri = rootUri.substring(7);
      }
    }

    List<License>? licenses;

    for (final fileName in possibleLicenseFileNames) {
      final file = File(join(rootUri, fileName));
      if (file.existsSync()) {
        // ignore: invalid_use_of_visible_for_testing_member
        licenses = await detectLicenseInFile(file, relativePath: file.path);
        break;
      }
    }

    if (licenses != null && licenses.isNotEmpty) {
      for (final license in licenses) {
        res.add({'name': name, 'license': license.spdxIdentifier});
      }
    } else {
      res.add({'name': name, 'license': 'No license file'});
    }
  }

  switch (outputFormat) {    
    case 'tsv':
      print('Package\tLicense');
      for(final e in res) {
        print('${e['name']}\t${e['license']}');
      }
      break;
    case 'csv':
      print('Package,License');
      for(final e in res) {
        print('"${e['name']}","${e['license']}"');
      }
      break;
    case 'json':
    default:
      final encoder = prettyPrint
          ? const JsonEncoder.withIndent('  ')
          : const JsonEncoder();
      print(encoder.convert(res));
      break;
  }
}

// TODO LGPL, AGPL, MPL

const permissiveLicenses = [
  'MIT',
  'BSD',
  'BSD-1-Clause',
  'BSD-2-Clause-Patent',
  'BSD-2-Clause-Views',
  'BSD-2-Clause',
  'BSD-3-Clause-Attribution',
  'BSD-3-Clause-Clear',
  'BSD-3-Clause-LBNL',
  'BSD-3-Clause-Modification',
  'BSD-3-Clause-No-Military-License',
  'BSD-3-Clause-No-Nuclear-License-2014',
  'BSD-3-Clause-No-Nuclear-License',
  'BSD-3-Clause-No-Nuclear-Warranty',
  'BSD-3-Clause-Open-MPI',
  'BSD-3-Clause',
  'BSD-4-Clause-Shortened',
  'BSD-4-Clause-UC',
  'BSD-4-Clause',
  'BSD-Protection',
  'BSD-Source-Code',
  'Apache',
  'Apache-1.0',
  'Apache-1.1',
  'Apache-2.0',
  'Unlicense',
];

const copyleftOrProprietaryLicenses = [
  'GPL',
  'GPL-1.0',
  'GPL-2.0',
  'GPL-3.0',
];
