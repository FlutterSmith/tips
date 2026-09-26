import 'dart:io';

import 'package:path/path.dart' as p;

import 'model.dart';
import 'repo.dart';

/// Turns a title into a URL slug: "Column(spacing:) is here" →
/// "column-spacing-is-here".
String slugify(String title) => title
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

String _snake(String slug) => slug.replaceAll('-', '_');

/// Creates a draft tip with its example and test. Returns created paths.
List<String> scaffold(
  Repo repo, {
  required String title,
  required Category category,
  String? slug,
  DateTime? today,
}) {
  final id = slug ?? slugify(title);
  if (id.isEmpty) throw ArgumentError('Title must contain letters or digits.');
  final date = (today ?? DateTime.now()).toIso8601String().substring(0, 10);

  final files = {
    p.join(repo.tipsDir, id, 'index.md'):
        '''
---
slug: $id
title: $title
summary: One sentence on what the reader gets out of this tip.
category: ${category.name}
tags: []
level: beginner
published: $date
status: draft
---

Start with the problem in one sentence.

<?code-excerpt "$id/example.dart" region="main"?>
```dart
```

Then explain why it works, and what to watch out for.
''',
    p.join(repo.examplesDir, 'lib', 'tips', id, 'example.dart'): '''
// #docregion main
void example() {
  // Real, compiling code goes here. A `// @note text` line annotates
  // the line below it.
}
// #enddocregion main
''',
    p.join(repo.examplesDir, 'test', 'tips', '${_snake(id)}_test.dart'):
        '''
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/$id/example.dart';

void main() {
  test('$title', () {
    expect(example, returnsNormally);
  });
}
''',
  };

  final existing = files.keys.where((f) => File(f).existsSync());
  if (existing.isNotEmpty) {
    throw StateError(
      'Already exists: ${existing.map(repo.relative).join(', ')}',
    );
  }
  for (final entry in files.entries) {
    File(entry.key)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(entry.value);
  }
  return files.keys.map(repo.relative).toList();
}
