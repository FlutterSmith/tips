import 'package:test/test.dart';
import 'package:tips_cli/tips_cli.dart';

void main() {
  group('extractRegion', () {
    const source = '''
import 'dart:async';

// #docregion helper
Future<void> helper() async {
  // #docregion inner
  final x = 1; // @note a note
  // #enddocregion inner
  print(x);
}
// #enddocregion helper
''';

    test('returns the whole file without markers', () {
      final code = extractRegion(source);
      expect(code, isNot(contains('#docregion')));
      expect(code, startsWith("import 'dart:async';"));
      expect(code, endsWith('}'));
    });

    test('returns a region and keeps @note comments', () {
      expect(extractRegion(source, region: 'helper'), '''
Future<void> helper() async {
  final x = 1; // @note a note
  print(x);
}''');
    });

    test('dedents nested regions', () {
      expect(
        extractRegion(source, region: 'inner'),
        'final x = 1; // @note a note',
      );
    });

    test('joins disjoint parts with a plaster line', () {
      const split = '''
class A {
  // #docregion r
  void a() {}
  // #enddocregion r
  void hidden() {}
  // #docregion r
  void b() {}
  // #enddocregion r
}
''';
      expect(
        extractRegion(split, region: 'r'),
        'void a() {}\n// ···\nvoid b() {}',
      );
    });

    test('throws for a missing region', () {
      expect(
        () => extractRegion(source, region: 'nope'),
        throwsA(isA<ExcerptException>()),
      );
    });

    test('supports comma-separated region names', () {
      const multi = '// #docregion a, b\nx();\n// #enddocregion a, b\n';
      expect(extractRegion(multi, region: 'b'), 'x();');
    });
  });

  group('syncMarkdown', () {
    String? reader(String path) => path == 'tip/a.dart'
        ? '// #docregion r\nfinal a = 1;\n// #enddocregion r\n'
        : null;

    test('replaces the fence after a marker', () {
      const md =
          'Intro\n\n<?code-excerpt "tip/a.dart" region="r"?>\n'
          '```dart\nold\n```\n\nOutro\n';
      final result = syncMarkdown(md, reader, path: 'x.md');
      expect(result.issues, isEmpty);
      expect(result.markdown, contains('```dart\nfinal a = 1;\n```'));
      expect(result.markdown, isNot(contains('old')));
      expect(result.markdown, endsWith('Outro\n'));
      expect(result.excerpts, ['tip/a.dart']);
    });

    test('keeps the fence info string', () {
      const md =
          '<?code-excerpt "tip/a.dart" region="r"?>\n'
          '```dart dont="Avoid this"\n```\n';
      final result = syncMarkdown(md, reader, path: 'x.md');
      expect(
        result.markdown,
        startsWith(
          '<?code-excerpt "tip/a.dart" region="r"?>\n```dart dont="Avoid this"\n',
        ),
      );
    });

    test('is idempotent', () {
      const md = '<?code-excerpt "tip/a.dart" region="r"?>\n```dart\n```\n';
      final once = syncMarkdown(md, reader, path: 'x.md').markdown;
      expect(syncMarkdown(once, reader, path: 'x.md').markdown, once);
    });

    test('reports a missing source with its line', () {
      const md = 'a\n<?code-excerpt "tip/missing.dart"?>\n```dart\nkeep\n```\n';
      final result = syncMarkdown(md, reader, path: 'x.md', lineOffset: 10);
      expect(
        result.issues.single.toString(),
        'x.md:12: Excerpt source "tip/missing.dart" not found.',
      );
      expect(result.markdown, md);
    });

    test('reports a marker without a fence', () {
      const md = '<?code-excerpt "tip/a.dart"?>\n\ntext\n';
      expect(syncMarkdown(md, reader, path: 'x.md').issues, hasLength(1));
    });
  });
}
