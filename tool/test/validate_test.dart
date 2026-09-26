import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:tips_cli/tips_cli.dart';

import 'helpers.dart';

void main() {
  List<String> messages(Repo repo) =>
      validate(repo).map((i) => i.message).toList();

  test('a clean tip passes', () {
    final repo = fixtureRepo({
      'content/tags.yaml': tagsYaml,
      'content/tips/sample-tip/index.md': tipMd(
        body:
            '<?code-excerpt "sample-tip/a.dart"?>\n```dart\nfinal a = 1;\n```\n'
            '\n![A chart of timings](chart.png)\n',
      ),
      'content/tips/sample-tip/chart.png': 'png',
    });
    expect(validate(repo), isEmpty);
  });

  test('flags unknown tags, bad related links and long summaries', () {
    final repo = fixtureRepo({
      'content/tags.yaml': tagsYaml,
      'content/tips/sample-tip/index.md': tipMd(
        tags: '[nope]',
        extra: 'related: [ghost]\n',
      ).replaceFirst('A summary.', 'x' * 200),
    });
    expect(
      messages(repo),
      containsAll([
        contains('Unknown tag "nope"'),
        contains('Related tip "ghost" does not exist'),
        contains('Summary is 200 chars'),
      ]),
    );
  });

  test('requires dart fences to be excerpted or explicitly nocheck', () {
    final repo = fixtureRepo({
      'content/tags.yaml': tagsYaml,
      'content/tips/sample-tip/index.md': tipMd(
        body:
            '```dart\nfinal loose = 1;\n```\n\n'
            '<!-- nocheck: Riverpod 2 API, does not compile on 3 -->\n'
            '```dart nocheck\nold();\n```\n\n```\nno language\n```\n',
      ),
    });
    final found = validate(repo);
    expect(found.map((i) => i.message), [
      contains('must come from examples/'),
      contains('Give every code fence a language'),
    ]);
    expect(found.first.line, 12);
  });

  test('checks alt text, broken links, unreferenced and oversized assets', () {
    final repo = fixtureRepo({
      'content/tags.yaml': tagsYaml,
      'content/tips/sample-tip/index.md': tipMd(
        body: '![](a.png)\n\n[Other](../missing/index.md)\n',
      ),
      'content/tips/sample-tip/a.png': 'x' * (301 * 1024),
      'content/tips/sample-tip/unused.png': 'x',
    });
    expect(
      messages(repo),
      containsAll([
        contains('needs alt text'),
        contains('Broken link'),
        contains('not referenced'),
        contains('budget is 300 KB'),
      ]),
    );
  });

  test('enforces notes limits, banned phrases, emoji and length', () {
    final notes = List.generate(5, (i) => 'x(); // @note note $i').join('\n');
    final repo = fixtureRepo({
      'content/tags.yaml': tagsYaml,
      'content/tips/sample-tip/index.md': tipMd(
        body:
            'Did you know? This will supercharge your app 👇\n\n'
            '<?code-excerpt "a.dart"?>\n```dart\n$notes\n'
            'y(); // @note ${'long ' * 20}\n```\n\n'
            '${'word ' * 360}\n',
      ),
    });
    expect(
      messages(repo),
      containsAll([
        contains('"did you know"'),
        contains('"supercharge"'),
        contains('No emoji'),
        contains('6 notes in one snippet'),
        contains('Note is'),
        contains('words of prose'),
      ]),
    );
  });

  test('reports parse errors and invalid folder names', () {
    final repo = fixtureRepo({
      'content/tags.yaml': tagsYaml,
      'content/tips/Bad_Name/index.md': tipMd(slug: 'Bad_Name'),
      'content/tips/broken/index.md': '---\nslug: broken\n',
    });
    expect(
      messages(repo),
      containsAll([contains('not a valid slug'), contains('not closed')]),
    );
  });

  test('learning paths may only list published tips', () {
    final repo = fixtureRepo({
      'content/tags.yaml': tagsYaml,
      'content/tips/sample-tip/index.md': tipMd(status: 'draft'),
      'content/paths/start.yaml':
          'title: Start\nsummary: First steps\ntips: [sample-tip]\n',
    });
    expect(messages(repo), [contains('not a published tip')]);
  });

  test('ignores the generated nav block', () {
    final repo = fixtureRepo({
      'content/tags.yaml': tagsYaml,
      'content/tips/sample-tip/index.md': tipMd(
        body:
            'Body.\n\n<!-- tips:nav -->\n[x](../../../CATALOG.md) 👇\n'
            '<!-- /tips:nav -->\n',
      ),
    });
    expect(validate(repo), isEmpty);
    expect(File(p.join(repo.root, 'CATALOG.md')).existsSync(), isFalse);
  });
}
