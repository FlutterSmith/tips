import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'model.dart';
import 'repo.dart';
import 'validate.dart' show navEnd, navStart;

/// Upstream repository and the commit our adaptations are based on.
const upstreamRepo = 'https://github.com/bizz84/flutter-tips-and-tricks';
const upstreamCommit = '672140da1a286470bf2c3d70fed04884f22b4c84';

const catalogStart = '<!-- tips:catalog -->';
const catalogEnd = '<!-- /tips:catalog -->';
const attributionStart = '<!-- tips:attribution -->';
const attributionEnd = '<!-- /tips:attribution -->';

/// Planned file contents, keyed by path relative to the repository root.
typedef Outputs = Map<String, String>;

/// A published tip with its display number and neighbours.
class Numbered {
  Numbered(this.tip, this.number, this.path);

  final Tip tip;
  final int number;

  /// `content/tips/<slug>/index.md`
  final String path;
  Numbered? previous;
  Numbered? next;

  String get label => number.toString().padLeft(3, '0');
}

/// Assigns numbers to newly published tips, keeping existing ones stable.
///
/// New tips are numbered after the current maximum, oldest `published`
/// date first, then by slug.
Map<String, int> assignNumbers(List<Tip> tips, Map<String, int> lock) {
  final numbers = Map<String, int>.of(lock);
  var next = numbers.values.fold(0, (a, b) => a > b ? a : b) + 1;
  final fresh =
      tips
          .where((t) => t.status.isPublished && !numbers.containsKey(t.slug))
          .toList()
        ..sort((a, b) {
          final byDate = a.published.compareTo(b.published);
          return byDate != 0 ? byDate : a.slug.compareTo(b.slug);
        });
  for (final tip in fresh) {
    numbers[tip.slug] = next++;
  }
  return numbers;
}

/// Everything `tips generate` writes. With [site], also the JSON the
/// website reads (`site/src/generated/meta.json`).
Outputs plan(
  Repo repo, {
  bool site = false,
  String? dartVersion,
  String? verifiedAt,
}) {
  final files = repo.loadTips();
  final broken = files.where((f) => f.tip == null).map((f) => f.path);
  if (broken.isNotEmpty) {
    throw StateError(
      'Fix these tips first (run `tips validate`): '
      '${broken.join(', ')}',
    );
  }
  final tips = [for (final f in files) f.tip!];
  final numbers = assignNumbers(tips, repo.loadNumbers());

  final listed = [
    for (final f in files)
      if (f.tip!.status.isPublished && f.tip!.status != Status.archived)
        Numbered(f.tip!, numbers[f.slug]!, f.path),
  ]..sort((a, b) => a.number.compareTo(b.number));
  for (var i = 0; i < listed.length; i++) {
    listed[i]
      ..previous = i > 0 ? listed[i - 1] : null
      ..next = i < listed.length - 1 ? listed[i + 1] : null;
  }
  final byslug = {for (final n in listed) n.tip.slug: n};

  final outputs = <String, String>{
    'content/numbers.lock': _numbersLock(numbers),
    'CATALOG.md': _catalog(listed),
  };

  for (final f in files) {
    outputs[f.path] = withNav(f.text, byslug[f.slug]);
  }

  final readme = repo.file('README.md');
  if (readme.existsSync()) {
    outputs['README.md'] = replaceBetween(
      readme.readAsStringSync(),
      catalogStart,
      catalogEnd,
      _readmeCatalog(listed),
    );
  }
  final attribution = repo.file('ATTRIBUTION.md');
  if (attribution.existsSync()) {
    outputs['ATTRIBUTION.md'] = replaceBetween(
      attribution.readAsStringSync(),
      attributionStart,
      attributionEnd,
      _attributionTable(listed),
    );
  }
  if (site) {
    outputs['site/src/generated/meta.json'] = _siteMeta(
      repo,
      files,
      numbers,
      listed,
      dartVersion: dartVersion,
      verifiedAt: verifiedAt,
    );
  }
  return outputs;
}

/// Writes [outputs]; returns the paths whose contents changed.
List<String> write(Repo repo, Outputs outputs, {bool dryRun = false}) {
  final changed = <String>[];
  for (final entry in outputs.entries) {
    final file = repo.file(entry.key);
    final current = file.existsSync() ? file.readAsStringSync() : null;
    if (current == entry.value) continue;
    changed.add(entry.key);
    if (!dryRun) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
  }
  return changed..sort();
}

/// Replaces the text between two marker lines (markers kept).
String replaceBetween(String text, String start, String end, String inner) {
  final s = text.indexOf(start);
  final e = text.indexOf(end);
  if (s == -1 || e == -1 || e < s) {
    throw StateError('Missing "$start … $end" markers.');
  }
  return '${text.substring(0, s + start.length)}\n$inner\n${text.substring(e)}';
}

/// Adds, updates or (for unlisted tips) removes the generated nav block at
/// the end of a tip file.
String withNav(String text, Numbered? tip) {
  var body = text;
  final s = body.indexOf(navStart);
  if (s != -1) {
    final e = body.indexOf(navEnd, s);
    body =
        body.substring(0, s) +
        (e == -1 ? '' : body.substring(e + navEnd.length));
  }
  body = '${body.trimRight()}\n';
  if (tip == null) return body;

  String link(Numbered n) =>
      '[#${n.label} ${_md(n.tip.title)}]'
      '(../${n.tip.slug}/index.md)';
  final lines = [
    navStart,
    '',
    '---',
    '',
    '**#${tip.label}** · ${tip.tip.category.label} · '
        '[All tips](../../../CATALOG.md)',
    '',
    if (tip.previous != null) '← Previous: ${link(tip.previous!)}  ',
    if (tip.next != null) '→ Next: ${link(tip.next!)}',
    navEnd,
  ];
  return '$body\n${lines.join('\n')}\n';
}

String _md(String s) => s.replaceAll('|', r'\|');

String _numbersLock(Map<String, int> numbers) {
  final entries = numbers.entries.toList()
    ..sort((a, b) => a.value.compareTo(b.value));
  return [
    '# Stable display numbers. Generated by `tips generate`; never reuse one.',
    for (final e in entries) '${e.key}: ${e.value}',
    '',
  ].join('\n');
}

String _catalog(List<Numbered> listed) {
  final buf = StringBuffer()
    ..writeln('<!-- Generated by `tips generate`. Do not edit by hand. -->')
    ..writeln()
    ..writeln('# All tips')
    ..writeln()
    ..writeln('${listed.length} tips, newest first.')
    ..writeln()
    ..writeln('| # | Tip | Category | Level |')
    ..writeln('|--:|:--|:--|:--|');
  for (final n in listed.reversed) {
    buf.writeln(
      '| ${n.label} | [${_md(n.tip.title)}](${n.path}) | '
      '${n.tip.category.label} | ${n.tip.level.name} |',
    );
  }
  return buf.toString();
}

String _readmeCatalog(List<Numbered> listed) {
  final buf = StringBuffer();
  final categories = Category.values.where(
    (c) => listed.any((n) => n.tip.category == c),
  );
  buf
    ..writeln()
    ..writeln(
      '**${listed.length} tips** in ${categories.length} categories. '
      'Tap a category to open it.',
    )
    ..writeln();
  for (final category in categories) {
    final tips = listed.where((n) => n.tip.category == category).toList();
    buf
      ..writeln('<details>')
      ..writeln(
        '<summary><b>${category.label}</b> · ${tips.length} '
        '${tips.length == 1 ? 'tip' : 'tips'}</summary>',
      )
      ..writeln();
    for (final n in tips) {
      buf.writeln(
        '- `${n.label}` [${n.tip.title}](${n.path}): '
        '${n.tip.summary}',
      );
    }
    buf
      ..writeln()
      ..writeln('</details>');
  }
  return buf.toString().trimRight();
}

String _attributionTable(List<Numbered> listed) {
  final adapted = listed.where((n) => n.tip.origin != null).toList()
    ..sort(
      (a, b) => a.tip.origin!.upstreamId.compareTo(b.tip.origin!.upstreamId),
    );
  final buf = StringBuffer()
    ..writeln()
    ..writeln('| Upstream tip | This project | Relationship |')
    ..writeln('|:--|:--|:--|');
  for (final n in adapted) {
    final o = n.tip.origin!;
    buf.writeln(
      '| [#${o.upstreamId}]($upstreamRepo/blob/$upstreamCommit/'
      '${o.upstreamPath}) | [#${n.label} ${_md(n.tip.title)}](${n.path}) | '
      '${o.change.name} |',
    );
  }
  return buf.toString().trimRight();
}

String _siteMeta(
  Repo repo,
  List<TipFile> files,
  Map<String, int> numbers,
  List<Numbered> listed, {
  String? dartVersion,
  String? verifiedAt,
}) {
  final (paths, _) = repo.loadPaths();
  final byslug = {for (final n in listed) n.tip.slug: n};
  final json = {
    'flutter': repo.flutterVersion(),
    'dart': dartVersion ?? '',
    'verifiedAt': verifiedAt ?? '',
    'categories': [
      for (final c in Category.values)
        {
          'id': c.name,
          'label': c.label,
          'count': listed.where((n) => n.tip.category == c).length,
        },
    ],
    'tags': repo.loadTags(),
    'paths': [
      for (final path in paths)
        {
          'id': path.id,
          'title': path.title,
          'summary': path.summary,
          'tips': path.tips,
        },
    ],
    'tips': [
      for (final f in files)
        if (f.tip!.status.isPublished) _tipJson(repo, f, numbers, byslug),
    ],
    'upstream': {
      for (final f in files)
        if (f.tip!.status.isPublished && f.tip!.origin != null)
          '${f.tip!.origin!.upstreamId}': f.slug,
    },
  };
  return '${const JsonEncoder.withIndent('  ').convert(json)}\n';
}

Map<String, Object?> _tipJson(
  Repo repo,
  TipFile file,
  Map<String, int> numbers,
  Map<String, Numbered> byslug,
) {
  final tip = file.tip!;
  final n = byslug[tip.slug];
  final prose = tip.body
      .split(RegExp(r'^```', multiLine: true))
      .asMap()
      .entries
      .where((e) => e.key.isEven)
      .map((e) => e.value)
      .join(' ');
  final words = prose.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  final assetsDir = Directory(p.join(repo.tipsDir, tip.slug));
  return {
    'slug': tip.slug,
    'number': numbers[tip.slug],
    'title': tip.title,
    'summary': tip.summary,
    'category': tip.category.name,
    'tags': tip.tags,
    'level': tip.level.name,
    'published': tip.published.toIso8601String().substring(0, 10),
    'status': tip.status.name,
    'experimental': tip.experimental,
    'packages': tip.packages,
    'related': tip.related,
    'readingMinutes': ((words + 60) / 200).ceil(),
    'origin': tip.origin == null
        ? null
        : {
            'upstreamId': tip.origin!.upstreamId,
            'url':
                '$upstreamRepo/blob/$upstreamCommit/'
                '${tip.origin!.upstreamPath}',
            'change': tip.origin!.change.name,
            'credit': tip.origin!.creditVerb,
          },
    'previous': n?.previous?.tip.slug,
    'next': n?.next?.tip.slug,
    'assets':
        assetsDir
            .listSync(recursive: true)
            .whereType<File>()
            .map(
              (f) => p.posix.joinAll(
                p.split(p.relative(f.path, from: assetsDir.path)),
              ),
            )
            .where((f) => f != 'index.md')
            .toList()
          ..sort(),
  };
}
