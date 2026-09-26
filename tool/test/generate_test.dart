import 'dart:convert';

import 'package:test/test.dart';
import 'package:tips_cli/tips_cli.dart';

import 'helpers.dart';

void main() {
  Tip tip(String slug, String published, {String status = 'current'}) =>
      parseTip(slug, tipMd(slug: slug, published: published, status: status));

  group('assignNumbers', () {
    test('keeps locked numbers and appends new tips by date, then slug', () {
      final numbers = assignNumbers(
        [
          tip('b', '2026-01-02'),
          tip('a', '2026-01-02'),
          tip('old', '2025-01-01'),
          tip('first', '2026-01-01'),
          tip('wip', '2026-01-01', status: 'draft'),
        ],
        {'old': 7},
      );
      expect(numbers, {'old': 7, 'first': 8, 'a': 9, 'b': 10});
    });
  });

  group('plan', () {
    Repo repo() => fixtureRepo({
      'content/tags.yaml': tagsYaml,
      '.fvmrc': '{"flutter": "3.47.5"}',
      'README.md':
          'Intro\n<!-- tips:catalog -->\nold\n<!-- /tips:catalog -->\nEnd\n',
      'ATTRIBUTION.md':
          'Notice\n<!-- tips:attribution -->\n<!-- /tips:attribution -->\n',
      'content/tips/first/index.md': tipMd(
        slug: 'first',
        title: 'First',
        published: '2026-01-01',
      ),
      'content/tips/second/index.md': tipMd(
        slug: 'second',
        title: 'Second | piped',
        published: '2026-01-02',
        extra:
            'origin:\n  upstream_id: 116\n'
            '  upstream_path: tips/0116-measure-time/index.md\n'
            '  change: rewritten\n',
      ),
      'content/tips/draft/index.md': tipMd(
        slug: 'draft',
        title: 'Draft',
        status: 'draft',
      ),
    });

    test('numbers tips and links neighbours', () {
      final out = plan(repo());
      expect(out['content/numbers.lock'], contains('first: 1\nsecond: 2\n'));
      expect(
        out['content/tips/first/index.md'],
        contains('→ Next: [#002 Second \\| piped](../second/index.md)'),
      );
      expect(
        out['content/tips/second/index.md'],
        contains('← Previous: [#001 First](../first/index.md)'),
      );
      expect(out['content/tips/draft/index.md'], isNot(contains('tips:nav')));
    });

    test('fills README and ATTRIBUTION between markers', () {
      final out = plan(repo());
      expect(out['README.md'], startsWith('Intro\n<!-- tips:catalog -->\n'));
      expect(out['README.md'], contains('**2 tips** in 1 categories'));
      expect(out['README.md'], isNot(contains('old')));
      expect(out['README.md'], endsWith('<!-- /tips:catalog -->\nEnd\n'));
      expect(
        out['ATTRIBUTION.md'],
        contains(
          '[#116](https://github.com/'
          'bizz84/flutter-tips-and-tricks/blob/$upstreamCommit/'
          'tips/0116-measure-time/index.md)',
        ),
      );
      expect(out['CATALOG.md'], contains('| 002 | [Second \\| piped]'));
    });

    test('is stable once written', () {
      final r = repo();
      write(r, plan(r));
      expect(write(r, plan(r), dryRun: true), isEmpty);
    });

    test('writes site meta with credits and upstream redirects', () {
      final meta =
          jsonDecode(
                plan(
                  repo(),
                  site: true,
                  verifiedAt: '2026-09-21',
                )['site/src/generated/meta.json']!,
              )
              as Map<String, Object?>;
      expect(meta['flutter'], '3.47.5');
      expect(meta['verifiedAt'], '2026-09-21');
      expect(meta['upstream'], {'116': 'second'});
      final tips = (meta['tips'] as List).cast<Map<String, Object?>>();
      expect(tips.map((t) => t['slug']), ['first', 'second']);
      final second = tips.last;
      expect(second['previous'], 'first');
      expect((second['origin'] as Map)['credit'], 'Inspired by');
    });
  });

  test('withNav replaces an existing block', () {
    final once = withNav('Body\n', null);
    expect(once, 'Body\n');
    const text = 'Body\n\n<!-- tips:nav -->\nstale\n<!-- /tips:nav -->\n';
    expect(withNav(text, null), 'Body\n');
  });
}
