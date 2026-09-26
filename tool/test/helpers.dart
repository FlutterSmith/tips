import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tips_cli/tips_cli.dart';

/// Builds a throwaway repository from a map of relative path → contents.
Repo fixtureRepo(Map<String, String> files) {
  final root = Directory.systemTemp.createTempSync('tips_test_');
  Directory(p.join(root.path, 'content', 'tips')).createSync(recursive: true);
  for (final entry in files.entries) {
    File(p.join(root.path, entry.key))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(entry.value);
  }
  return Repo(root.path);
}

String tipMd({
  String slug = 'sample-tip',
  String title = 'A sample tip',
  String status = 'current',
  String published = '2026-10-01',
  String tags = '[dart3]',
  String extra = '',
  String body = 'Short body.\n',
}) =>
    '''
---
slug: $slug
title: $title
summary: A summary.
category: dart
tags: $tags
level: beginner
published: $published
status: $status
$extra---

$body''';

const tagsYaml = 'dart3: Dart 3 language features\nriverpod: Riverpod\n';
