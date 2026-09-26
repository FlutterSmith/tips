import 'issue.dart';

/// Marker line in Markdown: `<?code-excerpt "path" region="name"?>`.
final excerptPattern = RegExp(
  r'^<\?code-excerpt\s+"([^"]+)"(?:\s+region="([\w-]+)")?\s*\?>\s*$',
);

final _docregion = RegExp(r'#docregion\s+([\w-]+(?:\s*,\s*[\w-]+)*)');
final _enddocregion = RegExp(r'#enddocregion\s+([\w-]+(?:\s*,\s*[\w-]+)*)');

/// Shown between disjoint parts of the same region.
const plaster = '// ···';

/// Thrown when a region can't be extracted.
class ExcerptException implements Exception {
  const ExcerptException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Extracts [region] (or the whole file when null) from [source].
///
/// Marker lines are removed, disjoint parts of a region are joined with a
/// [plaster] line, and the result is dedented to its least indented line.
String extractRegion(String source, {String? region}) {
  final lines = source.replaceAll('\r\n', '\n').split('\n');
  final open = <String>{};
  final segments = <List<String>>[];
  var current = <String>[];
  var sawRegion = false;

  void closeSegment() {
    if (current.isNotEmpty) segments.add(current);
    current = <String>[];
  }

  for (final line in lines) {
    final start = _docregion.firstMatch(line);
    final end = _enddocregion.firstMatch(line);
    if (start != null) {
      final names = _names(start.group(1)!);
      open.addAll(names);
      if (region != null && names.contains(region)) sawRegion = true;
      continue;
    }
    if (end != null) {
      final names = _names(end.group(1)!);
      if (region != null && names.contains(region)) closeSegment();
      open.removeAll(names);
      continue;
    }
    if (region == null || open.contains(region)) current.add(line);
  }
  closeSegment();

  if (region != null && !sawRegion) {
    throw ExcerptException('Region "$region" not found.');
  }

  final joined = <String>[];
  for (final segment in segments) {
    final trimmed = _trimBlankEdges(segment);
    if (trimmed.isEmpty) continue;
    if (joined.isNotEmpty) joined.add('\u0000plaster');
    joined.addAll(trimmed);
  }
  final dedented = _dedent(joined);
  final indentOfFirst = dedented
      .firstWhere(
        (l) => l.trim().isNotEmpty && l != '\u0000plaster',
        orElse: () => '',
      )
      .indexOf(RegExp(r'\S'));
  return dedented
      .map(
        (l) => l == '\u0000plaster'
            ? '${' ' * (indentOfFirst < 0 ? 0 : indentOfFirst)}$plaster'
            : l,
      )
      .join('\n');
}

Set<String> _names(String group) =>
    group.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();

List<String> _trimBlankEdges(List<String> lines) {
  var start = 0;
  var end = lines.length;
  while (start < end && lines[start].trim().isEmpty) {
    start++;
  }
  while (end > start && lines[end - 1].trim().isEmpty) {
    end--;
  }
  return lines.sublist(start, end);
}

List<String> _dedent(List<String> lines) {
  var indent = -1;
  for (final line in lines) {
    if (line.trim().isEmpty || line == '\u0000plaster') continue;
    final lead = line.length - line.trimLeft().length;
    if (indent == -1 || lead < indent) indent = lead;
  }
  if (indent <= 0) return lines;
  return [
    for (final line in lines)
      line == '\u0000plaster' || line.length < indent
          ? line.trimLeft()
          : line.substring(indent),
  ];
}

/// Result of syncing one Markdown file.
class SyncResult {
  const SyncResult(this.markdown, this.issues, this.excerpts);

  final String markdown;
  final List<Issue> issues;

  /// Source paths referenced, relative to the examples package.
  final List<String> excerpts;
}

/// Loads an excerpt source by its marker path; returns null when missing.
typedef SourceReader = String? Function(String markerPath);

/// Rewrites every fenced block that follows an excerpt marker in [markdown]
/// with the current contents of its source region.
///
/// [path] and [lineOffset] only affect issue locations.
SyncResult syncMarkdown(
  String markdown,
  SourceReader read, {
  required String path,
  int lineOffset = 0,
}) {
  final lines = markdown.split('\n');
  final out = <String>[];
  final issues = <Issue>[];
  final excerpts = <String>[];

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final marker = excerptPattern.firstMatch(line);
    out.add(line);
    i++;
    if (marker == null) continue;

    final markerLine = lineOffset + i;
    if (i >= lines.length || !lines[i].startsWith('```')) {
      issues.add(
        Issue(
          path,
          'An excerpt marker must be followed directly by a ``` fence.',
          line: markerLine,
        ),
      );
      continue;
    }
    final fence = lines[i];
    var close = i + 1;
    while (close < lines.length && lines[close].trimRight() != '```') {
      close++;
    }
    if (close >= lines.length) {
      issues.add(Issue(path, 'Unclosed code fence.', line: markerLine + 1));
      out.addAll(lines.sublist(i));
      break;
    }

    final sourcePath = marker.group(1)!;
    final region = marker.group(2);
    excerpts.add(sourcePath);
    final source = read(sourcePath);
    if (source == null) {
      issues.add(
        Issue(
          path,
          'Excerpt source "$sourcePath" not found.',
          line: markerLine,
        ),
      );
      out.addAll(lines.sublist(i, close + 1));
    } else {
      try {
        final code = extractRegion(source, region: region);
        out
          ..add(fence)
          ..addAll(code.split('\n'))
          ..add('```');
      } on ExcerptException catch (e) {
        issues.add(Issue(path, '$sourcePath: $e', line: markerLine));
        out.addAll(lines.sublist(i, close + 1));
      }
    }
    i = close + 1;
  }
  return SyncResult(out.join('\n'), issues, excerpts);
}
