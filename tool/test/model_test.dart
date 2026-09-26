import 'package:test/test.dart';
import 'package:tips_cli/tips_cli.dart';

import 'helpers.dart';

void main() {
  group('parseTip', () {
    test('parses a complete tip', () {
      final tip = parseTip(
        'sample-tip',
        tipMd(
          extra:
              'origin:\n  upstream_id: 116\n'
              '  upstream_path: tips/0116-measure-time/index.md\n'
              '  change: rewritten\nrelated: [other]\n',
        ),
      );
      expect(tip.title, 'A sample tip');
      expect(tip.category, Category.dart);
      expect(tip.level, Level.beginner);
      expect(tip.published, DateTime(2026, 10, 1));
      expect(tip.origin!.upstreamId, 116);
      expect(tip.origin!.creditVerb, 'Inspired by');
      expect(tip.related, ['other']);
      expect(tip.body, '\nShort body.\n');
      expect(tip.bodyLineOffset, 15);
    });

    test('kept tips are credited as adapted', () {
      const origin = Origin(
        upstreamId: 1,
        upstreamPath: 'x',
        change: Change.modernized,
      );
      expect(origin.creditVerb, 'Adapted from');
    });

    test('rejects a slug that does not match the folder', () {
      expect(
        () => parseTip('other', tipMd()),
        throwsA(
          isA<TipFormatException>()
              .having((e) => e.message, 'message', contains('folder name'))
              .having((e) => e.line, 'line', 2),
        ),
      );
    });

    test('rejects unknown enum values with the allowed list', () {
      expect(
        () => parseTip('sample-tip', tipMd(status: 'done')),
        throwsA(
          isA<TipFormatException>().having(
            (e) => e.message,
            'message',
            contains('draft, current'),
          ),
        ),
      );
    });

    test('rejects unknown fields', () {
      expect(
        () => parseTip('sample-tip', tipMd(extra: 'author: me\n')),
        throwsA(
          isA<TipFormatException>().having(
            (e) => e.message,
            'message',
            contains('"author"'),
          ),
        ),
      );
    });

    test('rejects bad dates and missing frontmatter', () {
      expect(
        () => parseTip('sample-tip', tipMd(published: '12/10/2026')),
        throwsA(isA<TipFormatException>()),
      );
      expect(
        () => parseTip('sample-tip', '# No frontmatter'),
        throwsA(isA<TipFormatException>()),
      );
    });
  });
}
