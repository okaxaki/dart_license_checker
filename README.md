# Dart License Checker

Shows you which licenses your dependencies have.

```sh
$ dart run bin/dart_license_checker.dart -h          
-t, --show-transitive-dependencies    Show transitive dependencies.
-p, --pretty-print                    Pretty-print the results.
-f, --format                          Specify output format.
                                      [tsv, csv, json (default)]
-h, --help                            print this help.
```

```
[
  {
    "name": "args",
    "license": "BSD-3-Clause"
  },
  {
    "name": "pana",
    "license": "BSD-3-Clause"
  },
  {
    "name": "path",
    "license": "BSD-3-Clause"
  },
  {
    "name": "pubspec_parse",
    "license": "BSD-3-Clause"
  },
  {
    "name": "tint",
    "license": "MIT"
  }
]
```

## Install

`flutter pub global activate dart_license_checker`

## Use

- Make sure you are in the main directory of your Flutter app or Dart program
- Execute `dart_license_checker`

If this doesn't work, you may need to set up your PATH (see https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path)

## Showing transitive dependencies

By default, `dart_license_checker` only shows immediate dependencies (the packages you list in your `pubspec.yaml`).

If you want to analyze transitive dependencies too, you can use the `--show-transitive-dependencies` flag:

`dart_license_checker --show-transitive-dependencies`
