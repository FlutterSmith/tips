import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:tips_cli/tips_cli.dart';

import 'helpers.dart';

void main() {
  test('slugify', () {
    expect(slugify('Column(spacing:) is here!'), 'column-spacing-is-here');
    expect(slugify('  --Dart 3.13--  '), 'dart-3-13');
  });

  test('creates a draft that parses, and refuses to overwrite', () {
    final repo = fixtureRepo({});
    final created = scaffold(
      repo,
      title: 'Measure time',
      category: Category.dart,
      today: DateTime(2026, 10, 1),
    );
    expect(created, [
      'content/tips/measure-time/index.md',
      'examples/lib/tips/measure-time/example.dart',
      'examples/test/tips/measure_time_test.dart',
    ]);
    final text = File(p.join(repo.root, created.first)).readAsStringSync();
    final tip = parseTip('measure-time', text);
    expect(tip.status, Status.draft);
    expect(tip.published, DateTime(2026, 10, 1));
    final synced = syncMarkdown(text, repo.readExcerpt, path: created.first);
    expect(synced.issues, isEmpty);
    expect(synced.markdown, contains('void example() {'));
    expect(
      () => scaffold(repo, title: 'Measure time', category: Category.dart),
      throwsStateError,
    );
  });
}
