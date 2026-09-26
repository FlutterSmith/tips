import 'dart:io';

import 'package:path/path.dart' as p;

import 'excerpt.dart';
import 'issue.dart';
import 'model.dart';
import 'repo.dart';

const maxTitle = 80;
const maxSummary = 160;
const maxWords = 350;
const maxNotesPerSnippet = 4;
const maxNoteLength = 60;

/// Size budgets in bytes, by extension.
const assetBudgets = {
  '.png': 300 * 1024,
  '.jpg': 300 * 1024,
  '.jpeg': 300 * 1024,
  '.webp': 300 * 1024,
  '.svg': 100 * 1024,
  '.gif': 500 * 1024,
  '.mp4': 2 * 1024 * 1024,
  '.webm': 2 * 1024 * 1024,
};

/// Upstream branding we must never ship (see ATTRIBUTION.md).
const forbiddenAssets = {
  'code-with-andrea-banner.png',
  'social-media-banner.png',
  'flutter-tips-preview.png',
};

/// Phrases that make copy sound like marketing or a social post.
const bannedPhrases = [
  'did you know',
  'supercharge',
  'unlock the',
  'seamless',
  'game-changer',
  'game changer',
  'dive in',
  'dive into',
  "let's break it down",
  "in today's",
  'fast-paced',
  'show some love',
  'original tweet',
];

final _slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
final _image = RegExp(r'!\[([^\]]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)');
final _link = RegExp(r'(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)');
final _htmlSrc = RegExp(r'''(?:src|poster|href)="([^"]+)"''');
final _htmlImg = RegExp(r'<img\b[^>]*>');
final _note = RegExp(r'//\s*@note\s+(.*)$');
final _nocheckComment = RegExp(r'^<!--\s*nocheck:\s*\S.*-->\s*$');
final _pictograph = RegExp(
  r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{26FF}]',
  unicode: true,
);

const navStart = '<!-- tips:nav -->';
const navEnd = '<!-- /tips:nav -->';

/// Runs every content check and returns the issues found, sorted.
List<Issue> validate(Repo repo) {
  final issues = <Issue>[];
  final files = repo.loadTips();
  final tags = repo.loadTags();
  final slugs = {for (final f in files) f.slug};
  final published = {
    for (final f in files)
      if (f.tip?.status.isPublished ?? false) f.slug,
  };
  final titles = <String, String>{};

  for (final file in files) {
    if (!_slugPattern.hasMatch(file.slug)) {
      issues.add(
        Issue(
          file.path,
          'Folder name "${file.slug}" is not a valid slug '
          '(lowercase words joined by "-").',
        ),
      );
    }
    final tip = file.tip;
    if (tip == null) {
      issues.add(Issue(file.path, file.error!.message, line: file.error!.line));
      continue;
    }
    issues.addAll(_checkFrontmatter(file, tip, tags, slugs));
    final previous = titles[tip.title.toLowerCase()];
    if (previous != null) {
      issues.add(Issue(file.path, 'Title duplicates tip "$previous".'));
    }
    titles[tip.title.toLowerCase()] = tip.slug;
    issues.addAll(_checkBody(repo, file, tip));
    issues.addAll(_checkAssets(repo, file, tip));
  }

  final (paths, pathIssues) = repo.loadPaths();
  issues.addAll(pathIssues);
  for (final path in paths) {
    for (final slug in path.tips) {
      if (!published.contains(slug)) {
        issues.add(
          Issue(
            'content/paths/${path.id}.yaml',
            'Path lists "$slug", which is not a published tip.',
          ),
        );
      }
    }
  }
  return issues..sort();
}

Iterable<Issue> _checkFrontmatter(
  TipFile file,
  Tip tip,
  Map<String, String> tags,
  Set<String> slugs,
) sync* {
  if (tip.title.length > maxTitle) {
    yield Issue(
      file.path,
      'Title is ${tip.title.length} chars; keep it '
      'under $maxTitle.',
    );
  }
  if (tip.summary.length > maxSummary) {
    yield Issue(
      file.path,
      'Summary is ${tip.summary.length} chars; keep it '
      'under $maxSummary.',
    );
  }
  if (tip.tags.isEmpty) yield Issue(file.path, 'Add at least one tag.');
  for (final tag in tip.tags) {
    if (!tags.containsKey(tag)) {
      yield Issue(
        file.path,
        'Unknown tag "$tag". Add it to content/tags.yaml '
        'or use an existing one.',
      );
    }
  }
  for (final slug in tip.related) {
    if (!slugs.contains(slug)) {
      yield Issue(file.path, 'Related tip "$slug" does not exist.');
    }
    if (slug == tip.slug) {
      yield Issue(file.path, 'A tip cannot relate to itself.');
    }
  }
}

Iterable<Issue> _checkBody(Repo repo, TipFile file, Tip tip) sync* {
  final lines = tip.body.split('\n');
  final dir = p.dirname(p.join(repo.root, file.path));
  var inFence = false;
  var inNav = false;
  var fenceIsDart = false;
  var fenceStart = 0;
  var notes = 0;
  var words = 0;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final lineNo = tip.bodyLineOffset + i + 1;

    if (line.trim() == navStart) inNav = true;
    if (inNav) {
      if (line.trim() == navEnd) inNav = false;
      continue;
    }

    if (line.startsWith('```')) {
      if (!inFence) {
        inFence = true;
        fenceStart = lineNo;
        notes = 0;
        final info = line.substring(3).trim().split(RegExp(r'\s+'));
        fenceIsDart = info.first == 'dart';
        if (fenceIsDart) {
          final previous = i > 0 ? lines[i - 1] : '';
          final excerpted = excerptPattern.hasMatch(previous);
          final nocheck =
              info.contains('nocheck') && _nocheckComment.hasMatch(previous);
          if (!excerpted && !nocheck) {
            yield Issue(
              file.path,
              'Dart code must come from examples/ via an excerpt marker, or '
              'be marked "```dart nocheck" after a '
              '"<!-- nocheck: reason -->" comment.',
              line: lineNo,
            );
          }
        }
        if (info.first.isEmpty) {
          yield Issue(
            file.path,
            'Give every code fence a language.',
            line: lineNo,
          );
        }
      } else {
        inFence = false;
        if (fenceIsDart && notes > maxNotesPerSnippet) {
          yield Issue(
            file.path,
            '$notes notes in one snippet; keep it to $maxNotesPerSnippet.',
            line: fenceStart,
          );
        }
      }
      continue;
    }

    if (inFence) {
      final note = _note.firstMatch(line);
      if (note != null) {
        notes++;
        final text = note.group(1)!.trim();
        if (text.length > maxNoteLength) {
          yield Issue(
            file.path,
            'Note is ${text.length} chars; keep notes '
            'under $maxNoteLength.',
            line: lineNo,
          );
        }
      }
      continue;
    }

    if (line.trimLeft().startsWith('<!--') || excerptPattern.hasMatch(line)) {
      continue;
    }
    words += line.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    final lower = line.toLowerCase();
    for (final phrase in bannedPhrases) {
      if (lower.contains(phrase)) {
        yield Issue(
          file.path,
          'Avoid "$phrase". Say the thing plainly.',
          line: lineNo,
        );
      }
    }
    if (_pictograph.hasMatch(line)) {
      yield Issue(file.path, 'No emoji in prose.', line: lineNo);
    }

    for (final m in _image.allMatches(line)) {
      if (m.group(1)!.trim().isEmpty) {
        yield Issue(
          file.path,
          'Image "${m.group(2)}" needs alt text.',
          line: lineNo,
        );
      }
      yield* _checkTarget(file, dir, m.group(2)!, lineNo);
    }
    for (final m in _htmlImg.allMatches(line)) {
      if (!RegExp(r'alt="[^"]+"').hasMatch(m.group(0)!)) {
        yield Issue(
          file.path,
          '<img> needs a non-empty alt attribute.',
          line: lineNo,
        );
      }
    }
    for (final m in _link.allMatches(line)) {
      yield* _checkTarget(file, dir, m.group(1)!, lineNo);
    }
    for (final m in _htmlSrc.allMatches(line)) {
      yield* _checkTarget(file, dir, m.group(1)!, lineNo);
    }
  }

  if (inFence) {
    yield Issue(file.path, 'Unclosed code fence.', line: fenceStart);
  }
  if (words > maxWords) {
    yield Issue(file.path, '$words words of prose; keep tips under $maxWords.');
  }
}

Iterable<Issue> _checkTarget(
  TipFile file,
  String dir,
  String target,
  int line,
) sync* {
  if (RegExp(r'^[a-z]+:').hasMatch(target) || target.startsWith('#')) return;
  final withoutAnchor = target.split('#').first;
  if (withoutAnchor.isEmpty) return;
  if (!File(p.normalize(p.join(dir, withoutAnchor))).existsSync()) {
    yield Issue(file.path, 'Broken link: "$target".', line: line);
  }
}

Iterable<Issue> _checkAssets(Repo repo, TipFile file, Tip tip) sync* {
  final dir = Directory(p.dirname(p.join(repo.root, file.path)));
  final assets = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => p.basename(f.path) != 'index.md');
  for (final asset in assets) {
    final rel = p.posix.joinAll(
      p.split(p.relative(asset.path, from: dir.path)),
    );
    final path = repo.relative(asset.path);
    if (forbiddenAssets.contains(p.basename(asset.path))) {
      yield Issue(path, 'Upstream branding must not be used.');
    }
    if (!tip.body.contains(rel)) {
      yield Issue(path, 'Asset is not referenced by ${file.path}.');
    }
    final budget = assetBudgets[p.extension(asset.path).toLowerCase()];
    final size = asset.lengthSync();
    if (budget == null) {
      yield Issue(path, 'Unsupported asset type.');
    } else if (size > budget) {
      yield Issue(
        path,
        'Asset is ${size ~/ 1024} KB; the budget is '
        '${budget ~/ 1024} KB.',
      );
    }
  }
}
